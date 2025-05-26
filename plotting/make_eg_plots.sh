#!/bin/bash
# make_eg_plots.sh, draw L1Studies plots from histos obtained with the ZToEE skim

# CL arguments
dir=$1
lumi=$2
nvtx_suffix=$3

# if there is a nvtx_suffix, add the corresponding argument in the command aliases. Otherwise leave it blank
echo "$nvtx_suffix"
if [ -z "$nvtx_suffix" ]
then
    nvtx_arg=""
else
    nvtx_arg="--nvtx_suffix $nvtx_suffix"
fi

# some aliases (the drawplot.py must be in the same directory as the script, otherwise modify the path)
makeeff="python3 $PWD/drawplots.py -t efficiency --saveplot True $nvtx_arg"
makeprof="python3 $PWD/drawplots.py -t profilex_fromh2 --saveplot True $nvtx_arg"
makeresol="python3 $PWD/drawplots.py -t resolvsx --saveplot True $nvtx_arg"
makedist="python3 $PWD/drawplots.py -t distribution --saveplot True $nvtx_arg"

# move to workdir
cd $dir
filezee=all_ZToEE.root

# set some labels
toplabel="#sqrt{s} = 13.6 TeV, L_{int} = $lumi fb^{-1}"
#toplabel="$lumi"

# distribution of nvtx
if [ -z "$nvtx_suffix" ]
then
    $makedist -i $filezee \
        --h1d h_nvtx \
        --xtitle 'N_{vtx}' \
        --ytitle 'Events' \
        --toplabel "$toplabel" \
        --plotname L1EG_nvtx
fi

for range in "barrel" "endcap"
do
    case $range in 
        "barrel")
            eta_range="eta0p0to1p479"
            eta_label='{0.0 #leq |#eta^{e}(reco)| < 1.479}'
            ;;

        "endcap")
            eta_range="eta1p479to2p5"
            eta_label='{1.479 #leq |#eta^{e}(reco)| < 2.5}'
            ;;
        *)
            ;;
    esac

    # Efficiency vs Run Number
    # all eta ranges

    $makeeff -i $filezee \
        --den h_PlateauEffVsRunNb_Denominator_EGNonIso_plots_"$eta_range" \
        --num h_PlateauEffVsRunNb_Numerator_EGNonIso_plots_"$eta_range" h_PlateauEffVsRunNb_Numerator_EGLooseIso_plots_"$eta_range" h_PlateauEffVsRunNb_Numerator_EGLooseIso_plots_"$eta_range"  \
        --xtitle 'run number' \
        --ytitle 'Efficiency' \
        --legend 'Non iso' 'Loose iso' 'Tight iso' \
        --extralabel "#splitline{Z#rightarrowee, p_{T}^{e}(reco) #geq 35 GeV}$eta_label" \
        --toplabel "$toplabel" \
        --plotname L1EG_EffVsRunNb_"$range"

    for reco in "NonIso" "LooseIso" "TightIso"
    do
        # Efficiency vs pT
        # all eta ranges and all qualities

        $makeeff -i $filezee \
            --den h_EG"$reco"_plots_"$eta_range" \
            --num h_EG"$reco"_plots_"$eta_range"_l1thrgeq5 h_EG"$reco"_plots_"$eta_range"_l1thrgeq10 h_EG"$reco"_plots_"$eta_range"_l1thrgeq15 h_EG"$reco"_plots_"$eta_range"_l1thrgeq20 h_EG"$reco"_plots_"$eta_range"_l1thrgeq25 h_EG"$reco"_plots_"$eta_range"_l1thrgeq30 h_EG"$reco"_plots_"$eta_range"_l1thrgeq36 h_EG"$reco"_plots_"$eta_range"_l1thrgeq37 \
            --xtitle 'p_{T}^{e}(reco) (GeV)' \
            --ytitle "Efficiency" \
            --legend 'p_{T}^{L1 e} #geq 5 GeV' 'p_{T}^{L1 e} #geq 10 GeV' 'p_{T}^{L1 e} #geq 15 GeV' 'p_{T}^{L1 e} #geq 20 GeV' 'p_{T}^{L1 e} #geq 25 GeV' 'p_{T}^{L1 e} #geq 30 GeV' 'p_{T}^{L1 e} #geq 36 GeV' 'p_{T}^{L1 e} #geq 37 GeV' \
            --extralabel "#splitline{Z#rightarrowee, $reco}$eta_label" \
            --setlogx True \
            --toplabel "$toplabel" \
            --plotname L1EG_TurnOn"$reco"_"$range" 

        # same thing, zoom on the 0 - 50 GeV region in pT

        $makeeff -i $filezee \
            --den h_EG"$reco"_plots_"$eta_range" \
            --num h_EG"$reco"_plots_"$eta_range"_l1thrgeq5 h_EG"$reco"_plots_"$eta_range"_l1thrgeq10 h_EG"$reco"_plots_"$eta_range"_l1thrgeq15 h_EG"$reco"_plots_"$eta_range"_l1thrgeq20 h_EG"$reco"_plots_"$eta_range"_l1thrgeq25 h_EG"$reco"_plots_"$eta_range"_l1thrgeq30 h_EG"$reco"_plots_"$eta_range"_l1thrgeq36 h_EG"$reco"_plots_"$eta_range"_l1thrgeq37 \
            --xtitle 'p_{T}^{e}(reco) (GeV)' \
            --ytitle "Efficiency" \
            --legend 'p_{T}^{L1 e} #geq 5 GeV' 'p_{T}^{L1 e} #geq 10 GeV' 'p_{T}^{L1 e} #geq 15 GeV' 'p_{T}^{L1 e} #geq 20 GeV' 'p_{T}^{L1 e} #geq 25 GeV' 'p_{T}^{L1 e} #geq 30 GeV' 'p_{T}^{L1 e} #geq 36 GeV' 'p_{T}^{L1 e} #geq 37 GeV' \
            --extralabel "#splitline{Z#rightarrowee, $reco}$eta_label" \
            --setlogx True \
            --toplabel "$toplabel" \
            --axisranges 10 50 \
            --plotname L1EG_TurnOn"$reco"_"$range"_Zoom

        if [ -z "$nvtx_suffix" ]
        then

            $makeeff -i $filezee \
                --den h_EG"$reco"_plots_"$eta_range"_nvtx10to20 h_EG"$reco"_plots_"$eta_range"_nvtx20to30 h_EG"$reco"_plots_"$eta_range"_nvtx30to40 h_EG"$reco"_plots_"$eta_range"_nvtx40to50 h_EG"$reco"_plots_"$eta_range"_nvtx50to60 \
                --num h_EG"$reco"_plots_"$eta_range"_l1thrgeq10_nvtx10to20 h_EG"$reco"_plots_"$eta_range"_l1thrgeq10_nvtx20to30 h_EG"$reco"_plots_"$eta_range"_l1thrgeq10_nvtx30to40 h_EG"$reco"_plots_"$eta_range"_l1thrgeq10_nvtx40to50 h_EG"$reco"_plots_"$eta_range"_l1thrgeq10_nvtx50to60 \
                --xtitle 'p_{T}^{e}(reco) (GeV)' \
                --ytitle "Efficiency" \
                --legend 'nvtx #in #[]{10, 20}' 'nvtx #in #[]{20, 30}' 'nvtx #in #[]{30, 40}' 'nvtx #in #[]{40, 50}' 'nvtx #in #[]{50, 60}' \
                --extralabel "#splitline{Z#rightarrowee, $reco}{#splitline$eta_label{p_{T}^{L1 e} #geq 10 GeV}}" \
                --setlogx True \
                --toplabel "$toplabel" \
                --plotname L1EG_TurnOn"$reco"_"$range"_vsPU

            # same thing, zoom on the 0 - 50 GeV region in pT

            $makeeff -i $filezee \
                --den h_EG"$reco"_plots_"$eta_range"_nvtx10to20 h_EG"$reco"_plots_"$eta_range"_nvtx20to30 h_EG"$reco"_plots_"$eta_range"_nvtx30to40 h_EG"$reco"_plots_"$eta_range"_nvtx40to50 h_EG"$reco"_plots_"$eta_range"_nvtx50to60 \
                --num h_EG"$reco"_plots_"$eta_range"_l1thrgeq10_nvtx10to20 h_EG"$reco"_plots_"$eta_range"_l1thrgeq10_nvtx20to30 h_EG"$reco"_plots_"$eta_range"_l1thrgeq10_nvtx30to40 h_EG"$reco"_plots_"$eta_range"_l1thrgeq10_nvtx40to50 h_EG"$reco"_plots_"$eta_range"_l1thrgeq10_nvtx50to60 \
                --xtitle 'p_{T}^{e}(reco) (GeV)' \
                --ytitle "Efficiency" \
                --legend 'nvtx #in #[]{10, 20}' 'nvtx #in #[]{20, 30}' 'nvtx #in #[]{30, 40}' 'nvtx #in #[]{40, 50}' 'nvtx #in #[]{50, 60}' \
                --extralabel "#splitline{Z#rightarrowee, $reco}{#splitline$eta_label{p_{T}^{L1 e} #geq 10 GeV}}" \
                --setlogx True \
                --toplabel "$toplabel" \
                --axisranges 10 50 \
                --plotname L1EG_TurnOn"$reco"_"$range"_vsPU

        fi
    done
done

# Efficiency vs Eta Phi

$makeeff -i $filezee \
    --num h_EG25_EtaPhi_Numerator \
    --den h_EG25_EtaPhi_Denominator   \
    --xtitle '#eta^{e}(reco)' \
    --ytitle '#phi^{e}(reco)' \
    --ztitle 'L1EG25 efficiency (p_{T}^{e}(reco) > 30 GeV)' \
    --legend '' \
    --extralabel '#splitline{Z#rightarrowee}{L1 EG Tight Iso}' \
    --toplabel "$toplabel" \
    --plotname L1EG_EffVsEtaPhi \
    --axisranges -2.5 2.5 -3.1416 3.1416 0 1.1

$makeeff -i $filezee \
    --num h_EG25_Eta_Numerator \
    --den h_EG25_Eta_Denominator   \
    --xtitle '#eta^{e}(reco)' \
    # --ytitle '#phi^{e}(reco)' \
    --ytitle 'L1EG25 efficiency (p_{T}^{e}(reco) > 30 GeV)' \
    --legend '' \
    --extralabel '#splitline{Z#rightarrowee}' \
    --toplabel "$toplabel" \
    --plotname L1EG_EffVsEta \
    --axisranges -2.5 2.5 

# Postfiring vs Eta Phi

 $makeeff \
    -i $filezee \
    --num L1EG15to26_bxplus1_etaphi  \
    --den L1EG15to26_bx0_etaphi  \
    --xtitle '#eta^{e}(reco)' \
    --ytitle '#phi^{e}(reco)' \
    --ztitle 'bx+1 / (bx0 or bx+1)' \
    --legend '' \
    --extralabel '#splitline{Z#rightarrowee}{15 #leq p_{T}^{e}(L1) < 26, L1 EG Non Iso}' \
    --toplabel "$toplabel" \
    --plotname L1EG_PostfiringVsEtaPhi \
    --axisranges -2.5 2.5 -3.1416 3.1416 0 1.1 \
    --addnumtoden True

# Prefiring vs Eta Phi

 $makeeff -i $filezee \
    --num L1EG15to26_bxmin1_etaphi  \
    --den L1EG15to26_bx0_etaphi  \
    --xtitle '#eta^{e}(reco)' \
    --ytitle '#phi^{e}(reco)' \
    --ztitle 'bx-1 / (bx0 or bx-1)' \
    --legend '' \
    --extralabel '#splitline{Z#rightarrowee}{15 #leq p_{T}^{e}(L1) < 26, L1 EG Non Iso}' \
    --toplabel "$toplabel" \
    --plotname L1EG_PrefiringVsEtaPhi \
    --axisranges -2.5 2.5 -3.1416 3.1416 0 1.1 \
    --addnumtoden True

# Postfiring vs Eta only

$makeeff -i $filezee \
    --num L1EG15to26_bxplus1_eta \
    --den L1EG15to26_bx0_eta \
    --xtitle '#eta^{e}(reco)' \
    --ytitle 'bx+1 / (bx0 or bx+1)' \
    --legend '' \
    --extralabel '#splitline{Z#rightarrowee}{15 #leq p_{T}^{e}(L1) < 26, L1 EG Non Iso}' \
    --toplabel "$toplabel" \
    --plotname L1EG_PostfiringVsEta \
    --axisranges -2.5 2.5 0 1.1 \
    --addnumtoden True 

# Prefiring vs Eta only

$makeeff -i $filezee \
    --num L1EG15to26_bxmin1_eta \
    --den L1EG15to26_bx0_eta \
    --xtitle '#eta^{e}(reco)' \
    --ytitle 'bx-1 / (bx0 or bx-1)' \
    --legend '' \
    --extralabel '#splitline{Z#rightarrowee}{15 #leq p_{T}^{e}(L1) < 26, L1 EG Non Iso}' \
    --toplabel "$toplabel" \
    --plotname L1EG_PrefiringVsEta \
    --axisranges -2.5 2.5 0 1.1 \
    --addnumtoden True 

# Resolution vs Pt

$makeresol \
    -i $filezee \
    --h2d h_ResponseVsPt_EGNonIso_plots_eta0p0to1p479 h_ResponseVsPt_EGNonIso_plots_eta1p479to2p5  \
    --xtitle 'p_{T}^{reco e} (GeV)' \
    --ytitle '(p_{T}^{L1EG}/p_{T}^{reco e})' \
    --extralabel '#splitline{Z#rightarrowee}{Non Iso.}' \
    --legend '0 #leq |#eta| < 1.479' '1.479 #leq |#eta| < 2.5'  \
    --toplabel "$toplabel" \
    --plotname L1EG_ResponseVsPt \
    --axisranges 0 100 0 1.6 

# Response vs Run Number
$makeresol \
    -i $filezee \
    --h2d h_ResponseVsRunNb_EGNonIso_plots_eta0p0to1p479 h_ResponseVsRunNb_EGNonIso_plots_eta1p479to2p5  \
    --xtitle 'run number' \
    --ytitle '(p_{T}^{L1EG}/p_{T}^{reco e})' \
    --extralabel '#splitline{Z#rightarrowee}{Non Iso.}' \
    --legend '0 #leq |#eta| < 1.479' '1.479 #leq |#eta| < 2.5'  \
    --axisrange 355374 362760 0 2 \
    --toplabel "$toplabel" \
    --plotname L1EG_ResponseVsRunNb \
