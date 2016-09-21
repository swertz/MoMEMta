function append(t1, t2)
    for i = 1, #t2 do
        t1[#t1 + 1] = t2[i]
    end

    return t1
end


parameters = {
    energy = 13000.,
    higgs_mass = 125.09,
    higgs_width = 0.004,  --fix it???
}

cuba = {
    relative_accuracy = 0.01,
    verbosity = 3,
}


GaussianTransferFunctionOnEnergy.tf_p3 = {
    ps_point = add_dimension(),
    reco_particle = 'input::particles/3',
    sigma = 0.05,
}

BreitWignerGenerator.flatter_s12 = {
    -- add_dimension() generates an input tag of type `cuba::ps_points/i`
    -- where `i` is automatically incremented each time the function is called.
    -- This function allows MoMEMta to track how many dimensions are needed for the integration.
    ps_point = add_dimension(),
    mass = parameter('higgs_mass'),
    width = parameter('higgs_width'),
}

SecondaryBlockCD.secBlockCD = {
        s12 = 'flatter_s12::s',
        reco_p1 = 'input::particles/4',
        gen_p2 = 'tf_p3::output',
}

Looper.looperMB = {
    solutions = 'blockA::solutions',
    path = Path("boost", "tf_evaluator1", "tf_evaluator2", "HH_bbbb", "integrand"),
}

Looper.looperSB = {
    solutions = 'secBlockCD::gen_p1',
    path = Path("blockA", "tf_evaluator3", "looperMB"),
}

BlockA.blockA = {
  inputs = {
    'input::particles/1',
    'input::particles/2',
    'tf_p3::output',
    'looperSB::particles/1',  
  }
}

GaussianTransferFunctionOnEnergyEvaluator.tf_evaluator1 = {
    reco_particle = 'input::particles/1',
    gen_particle = 'looperMB::particles/1',
}

GaussianTransferFunctionOnEnergyEvaluator.tf_evaluator2 = {
    reco_particle = 'input::particles/2',
    gen_particle = 'looperMB::particles/2',
}

GaussianTransferFunctionOnEnergyEvaluator.tf_evaluator3 = {
    reco_particle = 'input::particles/4',
    gen_particle = 'looperSB::particles/1',
}

BuildInitialState.boost = {
  do_transverse_boost = true,
  particles = {
    'looperMB::particles/1',
    'looperMB::particles/2',
    'looperMB::particles/3',
    'looperMB::particles/4',
  }
}

StandardPhaseSpace.phaseSpaceOut = {
  particles = {
    'looperMB::particles/1',
    'looperMB::particles/2',
    'looperMB::particles/3',
    'looperMB::particles/4',
  }
}

jacobians = {'tf_p3::TF_times_jacobian', 'flatter_s12::jacobian'}

append(jacobians, {'phaseSpaceOut::phase_space'})

append(jacobians, {'looperMB::jacobian', 'looperSB::jacobian'})

append(jacobians, {'tf_evaluator1::TF', 'tf_evaluator2::TF', 'tf_evaluator3::TF'})


MatrixElement.HH_bbbb = {
  pdf = 'CT10nlo',
  pdf_scale = parameter('higgs_mass'),   --CHECK!!!!

  matrix_element = 'pp_hh_bbbb_SMEFT_FF_2_P1_Sigma_SMEFT_FF_2_gg_bbxbbx',
  matrix_element_parameters = {
      card = '../MatrixElements/Cards/param_card.dat'
  },

  override_parameters = {
      mdl_MT = parameter('higgs_mass'),   --CHECK!!!!!!!!
  },

  initialState = 'boost::partons',

  particles = {
    inputs = {
      'looperMB::particles/1',
      'looperMB::particles/2',
      'looperMB::particles/3',
      'looperMB::particles/4',
    },

    ids = {
      {
        pdg_id = 5,
        me_index = 1,
      },

      {  
        pdg_id = 5,
        me_index = 3,
      },

      {
        pdg_id = -5,
        me_index = 2,
      },

      {
        pdg_id = -5,
        me_index = 4,
      }
    } 
  },

  jacobians = jacobians
}

DoubleSummer.integrand = {
    input = "HH_bbbb::output"
}

-- End of loop

integrand("integrand::sum")

