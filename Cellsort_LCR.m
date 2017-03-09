%CellSort 1.0
%Todas las rutinas para encontrar las celulas LC dic14
%mu=0.5 funciona bien para thinned skull
%Encuentra las celulas automaticamente


%[mixedsig, mixedfilters, CovEvals, covtrace, movm, ...
 %   movtm] = CellsortPCA(fn, flims, nPCs, dsamp, outputdir, badframes)
 
fn=uigetfile('*.*','Choose video');

[mixedsig, mixedfilters, CovEvals, covtrace, movm, movtm] = CellsortPCA(fn, [],200,1,'',[]);
figure(1)
[PCuse] = CellsortChoosePCs(fn, mixedfilters); %Quitar las que son solo ruido

figure(2)
CellsortPlotPCspectrum(fn, CovEvals, PCuse);


mu=0.5; nIC=[]; %mu=0 ICA espacial; mu=1 ICA temporal
[ica_sig, ica_filters, ica_A, numiter] = CellsortICA(mixedsig, ...
    mixedfilters, CovEvals, PCuse, mu, nIC, [], [], 200);

f0_n=uigetfile('*.*','Choose image');
 f0=imread(f0_n); %MED funciona bien
 
figure(3) 
dt=1; ratebin=1; plottype=1; spt=[]; spc=[];
CellsortICAplot('contour', ica_filters, ica_sig, f0, [], dt, ratebin, plottype, [], spt, spc);

figure(4)
smwidth=3; thresh_seg=2; arealims=[150*3 500*2]; %[64 650]
[ica_segments, segmentlabel, segcentroid] = CellsortSegmentation(ica_filters, ...
smwidth, thresh_seg, arealims, 1);

flims=[]; subtractmean=1;
cell_sig = CellsortApplyFilter(fn, ica_segments, flims, movm, subtractmean);

thresh_spikes=2; deconvtau=100; normalization=1;
[spmat, spt, spc] = CellsortFindspikes(cell_sig, thresh_spikes, dt, deconvtau, normalization);

Coord_active=segcentroid;
% cell_sig_filter=lowpass_filter_ct2(cell_sig);
% cell_sig_df=gradient(cell_sig_filter);
% Spikes=(cell_sig_df>50)*1;
% xx=find(cell_sig_df<50);
% cell_sig_df(xx)=0;
% S_index=sindex(Spikes);
% figure; imagesc(S_index)
% 

