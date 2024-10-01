#!/usr/bin/env python
# coding: utf-8

import os, sys
import pandas as pd

import time, datetime

import uproot

import os
import subprocess
from glob import glob

import numpy as np


def hadd(target, sources):
    cmd = f"hadd -f -j {target} {' '.join(sources)}"
    subprocess.run(cmd, shell=True)
#     print(cmd)


www_path = "/eos/cms/store/group/dpg_trigger/comm_trigger/L1Trigger/cmsl1dpg/www/DQM/T0PromptNanoMonit/"
out_path_prefix = "/eos/cms/store/group/dpg_trigger/comm_trigger/L1Trigger/cmsl1dpg/www/DQM/T0PromptNanoMonit/Weekly/"
script_dir = "/eos/cms/store/group/dpg_trigger/comm_trigger/L1Trigger/cmsl1dpg/MacrosNtuples/l1macros"


fname = "/eos/cms/store/group/tsg/STEAM/OMSRateNtuple/2024/physics.root"
# fname = "/eos/user/s/sdonato/www/OMSRatesNtuple/OMSRatesNtuple/OMS_ntuplizer/2024_physics_merged.root"
f = uproot.open(fname)

df_oms = f["tree"].arrays(
    filter_name = [

        "month","day","year","hour","minute","second",
        "time",
        "beams_stable",
        "deadtime",
        "fill", "run",
        "lumisection",
        "pileup",
        "delivered_lumi_per_lumisection",
    ],
    library = "pd"
)

df_oms["time"] = pd.to_datetime(df_oms.time, unit='s', utc=True) + pd.offsets.DateOffset(years=2024-1970)
df_oms["intLumi"] = df_oms.delivered_lumi_per_lumisection.cumsum() / 1000

run_vs_time = df_oms.groupby("run").time.max()

week_today = pd.to_datetime(time.time(), unit = "s").isocalendar().week

week_runs = {}

for week in range(week_today, week_today-6, -1):
    print("Week", week)
    
    ### NOTE Shifting start of week to Sunday
    
    d = f"2024-W{week-1}"
    start_date = pd.to_datetime(datetime.datetime.strptime(d + '-7', "%G-W%V-%u")).date()
    d = f"2024-W{week}"
    end_date = pd.to_datetime(datetime.datetime.strptime(d + '-7', "%G-W%V-%u")).date()

    print(start_date, end_date)
    
    date = run_vs_time.dt.date
    runs = list((run_vs_time[(date >= start_date) & (date < end_date)]).index)
    print(runs)
    
    week_runs[week] = runs

config_dict = {
    "JetMET" : # for JetMET plots
        {
            "datasets" : ["JetMET0","JetMET1"],
            "eras" : ["Run2024*"],
            "scripts": [
#                 "python3 performances_nano.py -i $INFILE -o $OUTDIR/all_DiJet.root -c DiJet",  
                "python3 ../plotting/make_DiJet_plots.py --dir $OUTDIR --config ../config_cards/full_DiJet.yaml",
                ]
        },
    "EGamma" : # for JetMET plots
        {
            "datasets" : ["EGamma0","EGamma1"],
            "eras" : ["Run2024*"],
            "scripts": [
#                 "python3 performances_nano.py -i $INFILE -o $OUTDIR/all_PhotonJet.root -c PhotonJet",
#                 "python3 performances_nano.py -i $INFILE -o $OUTDIR/all_ZToEE.root -c ZToEE",

#                 ## OFF DQM
#                 "python3 performances_nano_dqmoff.py -i $INFILE -o $OUTDIR/oug_zee_dqmoff.root -c ZToEEDQMOff",
                ## Plot
                "python3 ../plotting/make_ZToEE_plots.py --dir $OUTDIR --config ../config_cards/full_ZToEE.yaml",
                "python3 ../plotting/make_PhotonJet_plots.py --dir $OUTDIR --config ../config_cards/full_PhotonJet.yaml",
            ]
        },
    "Muon" : # for JetMET plots
        {
            "datasets" : ["Muon0","Muon1"],
            "eras" : ["Run2024*"],
            "scripts" : [
#                 "/bin/python3 performances_nano.py -i $INFILE -o $OUTDIR/all_ZToMuMu.root -c ZToMuMu",
#                 "/bin/python3 performances_nano.py -i $INFILE -o $OUTDIR/all_MuonJet.root -c MuonJet",
#                 "/bin/python3 performances_nano.py -i $INFILE -o $OUTDIR/all_ZToTauTau.root -c ZToTauTau ",
#                 ## OFF DQM
#                 "/bin/python3 performances_nano_dqmoff.py -i $INFILE -o $OUTDIR/out_zmumu_dqmoffl.root -c ZToMuMuDQMOff",
#                 "/bin/python3 performances_nano_dqmoff.py -i $INFILE -o $OUTDIR/out_jets_dqmoff.root -c JetsDQMOff ",
#                 "/bin/python3 performances_nano_dqmoff.py -i $INFILE -o $OUTDIR/out_ztautau_dqmoff.root -c ZToTauTauDQMOff",
#                 "/bin/python3 performances_nano_dqmoff.py -i $INFILE -o $OUTDIR/out_zmumu_dqmoffl.root -c ZToMuMuDQMOff",
#                 "/bin/python3 performances_nano_dqmoff.py -i $INFILE -o $OUTDIR/out_etsum_dqmoff.root -c EtSumDQMOff",
                ## plotting
                "/bin/python3 ../plotting/make_ZToMuMu_plots.py --dir $OUTDIR --config ../config_cards/full_ZToMuMu.yaml",
                "/bin/python3 ../plotting/make_ZToTauTau_plots.py --dir $OUTDIR --config ../config_cards/full_ZToTauTau.yaml",
                "/bin/python3 ../plotting/make_MuonJet_plots.py --dir $OUTDIR --config ../config_cards/full_MuonJet.yaml",
                ]
        }
}


# In[57]:



for week, runs in week_runs.items():
    print("Week: ", week, "\truns: ", runs)
    
    for label, config in config_dict.items():

        out_web_path = f"{out_path_prefix}/Week{week}_{runs[0]}-{runs[-1]}/{label}/"
        plot_dir = out_web_path + "/plotsL1Run3"

        print(plot_dir)

        if os.path.exists(plot_dir):
            print(80*"#")
            print(plot_dir + " exists, skipping.")
            continue
        else:
            os.makedirs(plot_dir)

        print(80*"#")
        print(80*"#")
        print(f"  Hadding plots for {label}")
        print(80*"#")

        ## find files
        fnames = []
        for dataset in config["datasets"]:
            for era in config["eras"]:
                print(era, dataset)
                for run in runs:
                    fn = glob(f"{www_path}/{label}/{era}/{dataset}/*/{run}/*/all_*.root")
                    fnames += fn
        print(len(fnames))

        ## merge plots
        root_basenames = np.unique([os.path.basename(f) for f in fnames if "all_" in f])

        for root_basename in root_basenames:
            files_to_hadd = [f for f in fnames if os.path.basename(f)==root_basename]

            target = out_web_path + root_basename
            if os.path.exists(target): continue

            os.makedirs(os.path.dirname(target), exist_ok=True)
    #         print(target)

            print(f"Going to hadd files like {files_to_hadd[:1]} to {target}")
            hadd(target, files_to_hadd)
            
        ## Plotting
        for script in config["scripts"]:
            print(script)

            script = script.replace("$OUTDIR",out_web_path)

            print(f"Going to store output here: {out_web_path}")
            if "/" in script.split(" ")[-1]:
                log_fname = out_web_path + "/" + os.path.basename(script.split(" ")[-1])+".log"
            else:
                log_fname = out_web_path + "/" + script.split(" ")[-1]+".log"
            print(f"Writing logs to {log_fname}")
            with open(log_fname, "w") as f:
                ret = subprocess.run(
                    #script.split(" "), 
                    script,
                    shell = True, 
                    stdout=f, 
                    stderr=f,
                    cwd = script_dir,
                    )

