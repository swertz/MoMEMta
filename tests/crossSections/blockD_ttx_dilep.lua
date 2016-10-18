function append(t1, t2)
    for i = 1, #t2 do
        t1[#t1 + 1] = t2[i]
    end

    return t1
end

function copy_and_append(t1, t2)
    local t3 = {}

    append(t3, t1)
    append(t3, t2)

    return t3
end

M_W = 80.419002
M_TOP = 173.
W_W = 2.047600e+00
W_TOP = 1.491500e+00

parameters = {
    energy = 13000.,
}

cuba = {
    verbosity = 2,
    max_eval = 2000000000,
    relative_accuracy = 0.005,
    n_start = 100000000,   
    seed = 5468460,        
}

-- 'Flat' transfer functions to integrate over the visible particle's energies and angles
-- First |P|
FlatTransferFunctionOnP.tf_p_1 = {
    ps_point = add_dimension(),
    reco_particle = 'input::particles/1',
    min = 0.,
    max = parameters.energy/2,
}
FlatTransferFunctionOnP.tf_p_2 = {
    ps_point = add_dimension(),
    reco_particle = 'input::particles/2',
    min = 0.,
    max = parameters.energy/2,
}
FlatTransferFunctionOnP.tf_p_3 = {
    ps_point = add_dimension(),
    reco_particle = 'input::particles/3',
    min = 0.,
    max = parameters.energy/2,
}
FlatTransferFunctionOnP.tf_p_4 = {
    ps_point = add_dimension(),
    reco_particle = 'input::particles/4',
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
FlatTransferFunctionOnPhi.tf_phi_3 = {
    ps_point = add_dimension(),
    reco_particle = 'tf_p_3::output',
}
FlatTransferFunctionOnPhi.tf_phi_4 = {
    ps_point = add_dimension(),
    reco_particle = 'tf_p_4::output',
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
FlatTransferFunctionOnTheta.tf_theta_4 = {
    ps_point = add_dimension(),
    reco_particle = 'tf_phi_4::output',
}

inputs = {
  'tf_theta_1::output',
  'tf_theta_2::output',
  'tf_theta_3::output',
  'tf_theta_4::output',
}

BreitWignerGenerator.flatter_s13 = {
    ps_point = add_dimension(),
    mass = M_W,
    width = W_W
}

BreitWignerGenerator.flatter_s134 = {
    ps_point = add_dimension(),
    mass = M_TOP,
    width = W_TOP
}

BreitWignerGenerator.flatter_s25 = {
    ps_point = add_dimension(),
    mass = M_W,
    width = W_W
}

BreitWignerGenerator.flatter_s256 = {
    ps_point = add_dimension(),
    mass = M_TOP,
    width = W_TOP
}

StandardPhaseSpace.phaseSpaceOut = {
    particles = inputs
}

BlockD.blockd = {
    inputs = inputs,

    s13 = 'flatter_s13::s',
    s134 = 'flatter_s134::s',
    s25 = 'flatter_s25::s',
    s256 = 'flatter_s256::s',
}

-- Loop

Looper.looper = {
    solutions = "blockd::solutions",
    path = Path("initial_state", "dummy", "integrand")
}

    full_inputs = copy_and_append(inputs, {'looper::particles/1', 'looper::particles/2'})
    
    BuildInitialState.initial_state = {
        particles = full_inputs
    }

    jacobians = {
      'tf_p_1::TF_times_jacobian', 'tf_p_2::TF_times_jacobian', 'tf_p_3::TF_times_jacobian', 'tf_p_4::TF_times_jacobian', 
      'tf_phi_1::TF_times_jacobian', 'tf_phi_2::TF_times_jacobian', 'tf_phi_3::TF_times_jacobian', 'tf_phi_4::TF_times_jacobian', 
      'tf_theta_1::TF_times_jacobian', 'tf_theta_2::TF_times_jacobian', 'tf_theta_3::TF_times_jacobian', 'tf_theta_4::TF_times_jacobian', 
      'flatter_s13::jacobian', 'flatter_s134::jacobian', 'flatter_s25::jacobian', 'flatter_s256::jacobian',
      'looper::jacobian', 'phaseSpaceOut::phase_space'
    }

    MatrixElement.dummy = {
      pdf = 'CT10nlo',
      pdf_scale = parameter('top_mass'),

      matrix_element = 'pp_ttx_fully_leptonic',
      matrix_element_parameters = {
          card = '../MatrixElements/Cards/param_card.dat'
      },

      initialState = 'initial_state::partons',

      particles = {
        inputs = fullinputs,
        ids = {
          {
            pdg_id = -11,
            me_index = 1,
          },

          {
            pdg_id = 5,
            me_index = 3,
          },

          {
            pdg_id = 13,
            me_index = 4,
          },

          {
            pdg_id = -5,
            me_index = 6,
          },
          
          {
            pdg_id = 12,
            me_index = 2,
          },

          {
            pdg_id = -14,
            me_index = 5,
          }
        }
      },

      jacobians = jacobians
    }

    DoubleSummer.integrand = {
        input = "dummy::output"
    }

-- End of loop

integrand("integrand::sum")
