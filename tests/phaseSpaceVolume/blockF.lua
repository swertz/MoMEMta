local p1 = declare_input("p1")
local p2 = declare_input("p2")

load_modules('MatrixElements/dummy/libme_dummy.so')

parameters = {
    energy = 1000.,
    W_mass = 250.,
    W_width = 100.
}

cuba = {
    verbosity = 3,
    max_eval = 20000000000,
    relative_accuracy = 0.005,
    n_start = 10000000,
    seed = 5468960,
    ncores = 8,
    batch_size = 8000000
}

-- 'Flat' transfer functions to integrate over the visible particle's energies and angles
-- First |P|
FlatTransferFunctionOnP.tf_p_1 = {
    ps_point = add_dimension(),
    reco_particle = p1.reco_p4,
    min = 0.,
    max = parameters.energy/2,
}
FlatTransferFunctionOnP.tf_p_2 = {
    ps_point = add_dimension(),
    reco_particle = p2.reco_p4,
    min = 0.,
    max = parameters.energy/2,
}

-- Pass these outputs over for Phi
FlatTransferFunctionOnPhi.tf_phi_1 = {
    ps_point = add_dimension(),
    reco_particle = 'tf_p_1::output',
}
FlatTransferFunctionOnPhi.tf_phi_2 = {
    ps_point = add_dimension(),
    reco_particle = 'tf_p_2::output',
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

inputs = {
  'tf_theta_1::output',
  'tf_theta_2::output',
}

BreitWignerGenerator.flatter_s13 = {
    ps_point = add_dimension(),
    mass = parameter('W_mass'),
    width = parameter('W_width')
}

BreitWignerGenerator.flatter_s24 = {
    ps_point = add_dimension(),
    mass = parameter('W_mass'),
    width = parameter('W_width')
}

StandardPhaseSpace.phaseSpaceOut = {
    particles = inputs
}

BlockF.blockf = {
    inputs = inputs,

    s13 = 'flatter_s13::s',
    s24 = 'flatter_s24::s',
    q1 = add_dimension(),
    q2 = add_dimension()
}

-- Loop

Looper.looper = {
    solutions = "blockf::solutions",
    path = Path("initial_state", "dummy", "integrand")
}

    full_inputs = copy_and_append(inputs, {'looper::particles/1', 'looper::particles/2'})

    BuildInitialState.initial_state = {
        particles = full_inputs
    }

    jacobians = {
      'tf_p_1::TF_times_jacobian', 'tf_p_2::TF_times_jacobian',
      'tf_phi_1::TF_times_jacobian', 'tf_phi_2::TF_times_jacobian',
      'tf_theta_1::TF_times_jacobian', 'tf_theta_2::TF_times_jacobian',
      'flatter_s13::jacobian', 'flatter_s24::jacobian',
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
            { pdg_id = 1, me_index = 4 },
        }
      },

      jacobians = jacobians
    }

    DoubleLooperSummer.integrand = {
        input = "dummy::output"
    }

-- End of loop

integrand("integrand::sum")
