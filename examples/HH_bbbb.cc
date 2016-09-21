/*
 *  MoMEMta: a modular implementation of the Matrix Element Method
 *  Copyright (C) 2016  Universite catholique de Louvain (UCL), Belgium
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <momemta/ConfigurationReader.h>
#include <momemta/Logging.h>
#include <momemta/MoMEMta.h>
#include <momemta/Utils.h>

#include <chrono>

using namespace std::chrono;

int main(int argc, char** argv) {

    //UNUSED(argc);
    //UNUSED(argv);

    logging::set_level(boost::log::trivial::debug);

    ConfigurationReader configuration("../examples/HH_bbbb.lua");

    MoMEMta weight(configuration.freeze());

    // b-quark
    LorentzVector p1(15.68735, -189.8133, -210.1001, 288.65808);

    // Anti b-quark
    LorentzVector p2(-81.89723, -59.53946, -75.95126, 127.12102);

    // b-quark
    LorentzVector p3(84.728727, 127.45076, -243.5151, 289.04342);

    // Anti b-quark
    LorentzVector p4(-18.90508, 86.760458, -76.85704, 117.55769);

    auto start_time = system_clock::now();
    std::vector<std::pair<double, double>> weights = weight.computeWeights({p1, p2, p3, p4});
    auto end_time = system_clock::now();

    LOG(debug) << "Result:";
    for (const auto& r: weights) {
        LOG(debug) << r.first << " +- " << r.second;
    }

    LOG(info) << "Weight computed in " << std::chrono::duration_cast<milliseconds>(end_time - start_time).count() << "ms";


    return 0;
}


















