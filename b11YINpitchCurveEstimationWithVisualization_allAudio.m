clc;clear;close all; %clear sound

rdir='F:\0.birdsongQBH\audio';
addpath(genpath(rdir))
load('b8_output_audioData_withAonly.mat')

% PARAMETERS
fref=440;
Tamp=.1;
nstd=2.5;

clf
for na=1%:length(recDet)
    clc,disp(['------------------ audio ' num2str(na) '----------']) 
    
% AUDIO
    afile=[num2str(recDetA(na).id) '.wav'];
     [a,fs]=audioread(afile);
     a=a(:,1); % because YIN uses the first column of audio
    
% PITCH-CURVE ESTIMATION   
    out=yinK(afile);
    
% % IN KHZ
%     out.f0=2.^out.f0*fref/1000;
%     out.best=2.^out.best*fref/1000;
%     out.good=2.^out.good*fref/1000;  
    
    disp('READY')
    
    su=nanmean(out.best)+nstd*nanstd(out.best);
    sl=nanmean(out.best)-nstd*nanstd(out.best);
    
    out2.good=out.good;
    out2.good=out2.good.*(out2.good>sl); 
    out2.good=out2.good.*(out2.good<su);
    out2.good(out2.good==0)=NaN;
    
    
    

% VISUALIZE/LISTEN
    clear sound,sound(a,fs)
    clf,subplot(2,1,1),plot(out2.good,'.-'), 
    subplot(2,1,2),plot(out.good,'.-'),hold on,plot(out.best,'.-'),xlim([0 length(out.good)]),title(recDet(na).id)
    hold on, plot(repmat(su,1,length(out.good)),'r'),hold on,plot(repmat(sl,1,length(out.good)),'r')
    
    linkaxes
    
    
    %pause(length(a)/fs)




    
end

%%
% recDetA=recDet;
% c=0;
% for na=1:length(recDet)
% if isempty(strfind(recDet(na).q,'A'))
%     c=c+1;
%     recDetA(na-c)=[];
% end
% end
% save('b8_output_audioData_withAonly.mat','recDet','recMeta','recDetA')


%     pp=1; % do preprocessing?

% % PREPROCESSING
%     if pp==1
%         clf
%         a=a/max(abs(a)); 
%         sp=repmat(std(a),1,length(a));
%         sn=sp*-1; 
%         
% %         subplot(2,1,1),plot(a,'.'),hold on
% %         plot(sp),hold on,plot(sn)
%         
%         a(abs(a)<std(a))=NaN; 
% %         subplot(2,1,2),plot(a,'.')
%         audiowrite('temp.wav',a,fs)
% 
% % PITCH-CURVE ESTIMATION
%          out=yinK('temp.wav'); 
%     else,out=yinK(afile);
%     end
% %     pause(.4)