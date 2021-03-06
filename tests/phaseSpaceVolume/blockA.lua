local p1 = declare_input("p1")
local p2 = declare_input("p2")
local p3 = declare_input("p3")

load_modules('MatrixElements/dummy/libme_dummy.so')

parameters = {
    energy = 1000.,
}

cuba = {
    verbosity = 3,
    max_eval = 200000000,
    relative_accuracy = 0.001,
    n_start = 20000000,
    seed = 5468960,
    ncores = 8,
    batch_size = 8000000
}

-- 'Flat' transfer functions to integrate over the visible particle's energies and angles
-- First |P|: only the input not concerned by blockA is integrated over
FlatTransferFunctionOnP.tf_p_3 = {
    ps_point = add_dimension(),
    reco_particle = p3.reco_p4,
    min = 0.,
    max = parameters.energy/2,
}

-- Pass these outputs over for Phi: the two outputs of blockA are integrated over their angles
FlatTransferFunctionOnPhi.tf_phi_1 = {
    ps_point = add_dimension(),
    reco_particle = p1.reco_p4,
}
FlatTransferFunctionOnPhi.tf_phi_2 = {
    ps_point = add_dimension(),
    reco_particle = p2.reco_p4,
}
FlatTransferFunctionOnPhi.tf_phi_3 = {
    ps_point = add_dimension(),
    reco_particle = 'tf_p_3::output',
}

-- Finally, do Theta
FlatTransferFunctionOnTheta.tf_theta_1 = {
    ps_point = add_dimension(),
    reco_particle = 'tf_phi_1::output',
}
FlatTransferFunctionOnTheta.tf_theta_2 = {
    ps_point = add_dimension(),
    reco_particle = 'tf_phi_2::output',
}
FlatTransferFunctionOnTheta.tf_theta_3 = {
    ps_point = add_dimension(),
    reco_particle = 'tf_phi_3::output',
}

inputs = {
  'tf_theta_1::output',
  'tf_theta_2::output',
  'tf_theta_3::output',
}

-- Only compute phase-space on particle not concerned by the block
StandardPhaseSpace.phaseSpaceOut = {
    particles = { inputs[3] }
}

BlockA.blocka = {
    inputs = inputs,
}

-- Loop

Looper.looper = {
    solutions = "blocka::solutions",
    path = Path("initial_state", "dummy", "integrand")
}

    full_inputs = { 'looper::particles/1', 'looper::particles/2', inputs[3] }

    BuildInitialState.initial_state = {
        particles = full_inputs
    }

    jacobians = {
      'tf_p_3::TF_times_jacobian',
      'tf_phi_1::TF_times_jacobian', 'tf_phi_2::TF_times_jacobian', 'tf_phi_3::TF_times_jacobian',
      'tf_theta_1::TF_times_jacobian', 'tf_theta_2::TF_times_jacobian', 'tf_theta_3::TF_times_jacobian',
      'looper::jacobian', 'phaseSpaceOut::phase_space'
    }

    MatrixElement.dummy = {
      use_pdf = false,

      matrix_element = 'dummy_matrix_element',
      matrix_element_parameters = {},

      initialState = 'initial_state::partons',

      particles = {
        inputs = full_inputs,
        ids = {
            { pdg_id = 1, me_index = 1 },
            { pdg_id = 1, me_index = 2 },
            { pdg_id = 1, me_index = 3 },
        }
      },

      jacobians = jacobians
    }

    DoubleLooperSummer.integrand = {
        input = "dummy::output"
    }

-- End of loop

integrand("integrand::sum")
