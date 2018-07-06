function [ out ] = segmentPitchCurve( audio,fs )

if ischar(audio)
[a,fs] = audioread(audio);
else a = audio;
    if nargin<2 || isempty(fs), disp('Missing sampling rate'), end
end
a = mean(a,2); % take mean of the two channels if there are 2 

% xx=10;
subplot(3,1,1)
[r, fig]=yb_yinbird(a,fs);
f0=r.f0yinbird_hz;

thresh=.2;

shift=1;
f0right=[zeros(1,shift) f0];
f0left=[f0 zeros(1,shift) ];
chg=abs(f0left-f0right);
chg=chg(shift:shift-1+length(f0));
chg=(chg/max(chg));
chg(chg<.5)=0;

chg=(chg>0).* (.9);
chg=1-chg;


ap0=r.ap0;
pwr=r.pwr;

% ap0=sqrt(ap0);
% pwr=sqrt(pwr);

temp=((1*ap0) + (0*pwr));
% temp=temp./ (chg);

% SMOOTH
% wsize=3;
% hop=1;
% for nwin=1:length(temp)-wsize
%     place=nwin+floor(wsize/2);
%     beg=nwin*hop-hop+1;
%     win=temp(beg:beg+wsize-1);
%     comb(place)=mean(win);
% end
% comb(end:length(f0))=comb(end);
comb=temp;
comb=comb./ (chg);

f0_seg=f0;
f0_seg(ap0>            thresh          )=NaN;

f0_seg2=f0;
f0_seg2(comb>            thresh          )=NaN;

hold on, plot(r.timescale_sec,f0_seg,'k','linewidth',2)

subplot(3,1,2)
[~,fig]=yb_yinbird(a,fs);
hold on, plot(r.timescale_sec,f0_seg2,'k','linewidth',2)

subplot(3,1,3),plot(r.timescale_sec,ap0)
%hold on, plot(r.timescale_sec,pwr)
hold on, plot(r.timescale_sec,chg)
hold on, plot(r.timescale_sec,comb)
hold on, plot(r.timescale_sec,thresh*ones(size(r.timescale_sec)))
xlim([0 length(a)/fs])
ylim([0 1])
legend('aperiodicity','change','combination','threshold')

out=1;
end

