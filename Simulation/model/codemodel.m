%% MATLAB model for code-based IMMD inverter simulations
% Simulation parameters
Ts = 1e-6; % sec
Tfinal = 0.04; %sec
StepN = uint32(Tfinal/Ts);
StepN2 = Tfinal/Ts;

% Drive parameters
fsw = 1e3; % Hz
Vdc = 540; % Volts
Cdc = 100e-6; % Per series module group
Pout = 8e3/0.94; % W % Total output power
np = 2;
ns = 2;
n = ns*np;

% For simulations only
phase = [0 90 0 90];
Rin = 10;
Vin = Vdc + Rin*(Pout/Vdc);

% Motor parameters
Ef = 155; % Volts
Efm = Ef/ns;
Ls = 13.8e-3; % Henries
Lsm = Ls/n;
Rs = 1e-9; % Ohms
fout = 50; % Hz
wout = 2*pi*fout; % rad/sec
m = 3;

% Control parameter calculation
Poutm = Pout/n; % Watts
Is = Poutm/(Efm*m); % amps
Xsm = wout*Lsm; % Ohms
Vdrop = Is*Xsm; % Volts
Vt = sqrt(Efm^2+Vdrop^2); % Volts
Vdcm = Vdc/ns; % volts
ma = Vt*sqrt(3)/(Vdcm*0.612);
delta = acos(Efm/Vt); % radians
deltad = delta*180/pi; % degrees
pf = cos(delta);
%phase = [0 30 60 90];

currentime = 0;
count = 0;
InducedVoltagePhaseA = zeros(1,StepN);
InducedVoltagePhaseB = zeros(1,StepN);
InducedVoltagePhaseC = zeros(1,StepN);
ModSignalPhaseA = zeros(1,StepN);
ModSignalPhaseB = zeros(1,StepN);
ModSignalPhaseC = zeros(1,StepN);
CarrierSignal = zeros(n,StepN);
InverterVoltagePhaseA = zeros(n,StepN);
InverterVoltagePhaseB = zeros(n,StepN);
InverterVoltagePhaseC = zeros(n,StepN);
InverterVoltageVAB = zeros(n,StepN);
InverterVoltageVBC = zeros(n,StepN);
InverterVoltageVCA = zeros(n,StepN);
LineCurrentA = zeros(n,StepN);
LineCurrentB = zeros(n,StepN);
LineCurrentC = zeros(n,StepN);
DCLinkCurrent = zeros(np,StepN);
DCLinkVoltage = zeros(1,StepN);
DCLinkCapacitorCurrent = zeros(ns,StepN);

timeaxis = 0:Ts:Tfinal;

% Main loop
tic
while (1)
    count = count+1;
    currenttime = count*Ts;
    
    InducedVoltagePhaseA(count) = Efm*sqrt(2)*sin(wout*currenttime);
    InducedVoltagePhaseB(count) = Efm*sqrt(2)*sin(wout*currenttime-2*pi/3);
    InducedVoltagePhaseC(count) = Efm*sqrt(2)*sin(wout*currenttime-4*pi/3);
    
    ModSignalPhaseA(count) = ma*sin(wout*currenttime+delta);
    ModSignalPhaseB(count) = ma*sin(wout*currenttime+delta-2*pi/3);
    ModSignalPhaseC(count) = ma*sin(wout*currenttime+delta-4*pi/3);
    
    phase = [0 0 0 0];
    
    CarrierSignal(:,count) = carriergen(currenttime,1,-1,fsw,phase)';
    
    for index = 1:n
        
        if ModSignalPhaseA(count) >= CarrierSignal(index,count)
            InverterVoltagePhaseA(index,count) = Vdcm;
        end
        if ModSignalPhaseB(count) >= CarrierSignal(index,count)
            InverterVoltagePhaseB(index,count) = Vdcm;
        end
        if ModSignalPhaseC(count) >= CarrierSignal(index,count)
            InverterVoltagePhaseC(index,count) = Vdcm;
        end
        
        InverterVoltageVAB(index,count) = InverterVoltagePhaseA(index,count)...
            - InverterVoltagePhaseB(count);
        InverterVoltageVBC(index,count) = InverterVoltagePhaseB(index,count)...
            - InverterVoltagePhaseC(index,count);
        InverterVoltageVCA(index,count) = InverterVoltagePhaseC(index,count)...
            - InverterVoltagePhaseA(index,count);
        
        LineCurrentA(index,count+1) = LineCurrentA(index,count) + ...
            Ts*(InverterVoltageVAB(index,count)-InverterVoltageVCA(index,count)...
            -2*InducedVoltagePhaseA(count)+InducedVoltagePhaseB(count)...
            +InducedVoltagePhaseC(count))/(3*Lsm);
        
        LineCurrentB(index,count+1) = LineCurrentB(index,count) + ...
            Ts*(InverterVoltageVBC(index,count)-InverterVoltageVAB(index,count)...
            -2*InducedVoltagePhaseB(count)+InducedVoltagePhaseA(count)...
            +InducedVoltagePhaseC(count))/(3*Lsm);
        
        LineCurrentC(index,count+1) = LineCurrentC(index,count) + ...
            Ts*(InverterVoltageVCA(index,count)-InverterVoltageVBC(index,count)...
            -2*InducedVoltagePhaseC(count)+InducedVoltagePhaseB(count)...
            +InducedVoltagePhaseA(count))/(3*Lsm);
        
    end
    if currenttime > Tfinal
        break;
        % end of the4 simulation
    end
end

%%
for index = 1:n
LineCurrentA(index,:) = LineCurrentA(index,:) - mean(LineCurrentA(index,:));
LineCurrentB(index,:) = LineCurrentB(index,:) - mean(LineCurrentB(index,:));
LineCurrentC(index,:) = LineCurrentC(index,:) - mean(LineCurrentC(index,:));
%InverterVoltagePhaseA = InverterVoltagePhaseA - mean(InverterVoltagePhaseA);
%InverterVoltagePhaseB = InverterVoltagePhaseB - mean(InverterVoltagePhaseB);
%InverterVoltagePhaseC = InverterVoltagePhaseC - mean(InverterVoltagePhaseC);
end
toc
fprintf('Simulation finished.\n');


%%
% Plots
figure;
plot(timeaxis,LineCurrentA(1,1:StepN+1),'k-','Linewidth',1);
hold on;
plot(timeaxis,LineCurrentB(1,1:StepN+1),'r-','Linewidth',1);
hold on;
plot(timeaxis,LineCurrentC(1,1:StepN+1),'b-','Linewidth',1);
hold on;
%plot(timeaxis,DCLinkCurrent(1:StepN+1),'b-','Linewidth',1);
%hold on;
%plot(timeaxis,DCLinkCapacitorCurrent(1:StepN+1),'k-','Linewidth',1);
%hold on;
%plot(timeaxis,DCLinkVoltage(1:StepN+1),'r-','Linewidth',1);
%hold on;
%plot(timeaxis,InducedVoltagePhaseA,'m-','Linewidth',2);
%hold on;
%plot(timeaxis,ModSignalPhaseA*Vdcm*0.612*sqrt(2)/sqrt(3),'g-','Linewidth',2);
hold off;
grid on;
set(gca,'FontSize',12);
xlabel('Time (s)','FontSize',12,'FontWeight','Bold')
%ylabel('Motor Phase Induced Voltages (Volts)','FontSize',12,'FontWeight','Bold')
%legend('Phase-A','Phase-B','Phase-C');
%legend('Carrier Signal','Modulating Signal','PWM Output');
%ylim([-2 2]);
%xlim([0 0.02])



%%
%
figure;
%plot(timeaxis(1:StepN),ModSignalPhaseA(1:StepN),'b-','Linewidth',1);
%hold on;
%plot(timeaxis(1:StepN),ModSignalPhaseB(1:StepN),'b-','Linewidth',1);
%hold on;
%plot(timeaxis(1:StepN),ModSignalPhaseC(1:StepN),'b-','Linewidth',1);
%hold on;
plot(timeaxis(1:StepN),CarrierSignal(1,1:StepN),'r-','Linewidth',1);
hold on;
plot(timeaxis(1:StepN),CarrierSignal(2,1:StepN),'k-','Linewidth',1);
hold on;
plot(timeaxis(1:StepN),CarrierSignal(3,1:StepN),'m-','Linewidth',1);
hold on;
plot(timeaxis(1:StepN),CarrierSignal(4,1:StepN),'g-','Linewidth',1);
hold off;
grid on;
set(gca,'FontSize',12);
xlabel('Time (s)','FontSize',12,'FontWeight','Bold')
%ylabel('Motor Phase Induced Voltages (Volts)','FontSize',12,'FontWeight','Bold')
%legend('Phase-A','Phase-B','Phase-C');
%legend('Carrier Signal','Modulating Signal','PWM Output');
ylim([-2 2]);
%xlim([0 0.002])



%%

% LineCurrentA = LineCurrentA - mean(LineCurrentA);
% LineCurrentB = LineCurrentB - mean(LineCurrentB);
% LineCurrentC = LineCurrentC - mean(LineCurrentC);
% InverterVoltagePhaseA = InverterVoltagePhaseA - mean(InverterVoltagePhaseA);
% InverterVoltagePhaseB = InverterVoltagePhaseB - mean(InverterVoltagePhaseB);
% InverterVoltagePhaseC = InverterVoltagePhaseC - mean(InverterVoltagePhaseC);
% LineCurrentA = LineCurrentA(1:end-1);
% LineCurrentB = LineCurrentB(1:end-1);
% LineCurrentC = LineCurrentC(1:end-1);
% InverterVoltageVAB = InverterVoltageVAB - mean(InverterVoltageVAB);
% InverterVoltageVBC = InverterVoltageVBC - mean(InverterVoltageVBC);
% InverterVoltageVCA = InverterVoltageVCA - mean(InverterVoltageVCA);
% DCLinkCurrent = LineCurrentA.*InverterVoltagePhaseA/Vdcm + ...
%     LineCurrentB.*InverterVoltagePhaseB/Vdcm + ...
%     LineCurrentC.*InverterVoltagePhaseC/Vdcm;
% DCLinkAverageCurrent = mean(DCLinkCurrent);
% DCLinkCapacitorCurrent = -DCLinkCurrent + DCLinkAverageCurrent;
% DCLinkRMSCurrent = sqrt(sum(DCLinkCapacitorCurrent.^2)/(StepN2+1));
% PhaseARMSCurrent = sqrt(sum(LineCurrentA.^2)/(StepN2+1));
% PhaseBRMSCurrent = sqrt(sum(LineCurrentB.^2)/(StepN2+1));
% PhaseCRMSCurrent = sqrt(sum(LineCurrentC.^2)/(StepN2+1));
% InverterVoltagePhaseARMS = sqrt(sum(InverterVoltagePhaseA.^2)/(StepN2+1));
% InverterVoltagePhaseBRMS = sqrt(sum(InverterVoltagePhaseB.^2)/(StepN2+1));
% InverterVoltagePhaseVRMS = sqrt(sum(InverterVoltagePhaseC.^2)/(StepN2+1));
% InverterVoltageVABRMS = sqrt(sum(InverterVoltageVAB.^2)/(StepN2+1));
% InverterVoltageVBCRMS = sqrt(sum(InverterVoltageVBC.^2)/(StepN2+1));
% InverterVoltageVCARMS = sqrt(sum(InverterVoltageVCA.^2)/(StepN2+1));
% InducedVoltageARMS = sqrt(sum(InducedVoltagePhaseA.^2)/(StepN2));
% InducedVoltageBRMS = sqrt(sum(InducedVoltagePhaseB.^2)/(StepN2));
% InducedVoltageCRMS = sqrt(sum(InducedVoltagePhaseC.^2)/(StepN2));
%
% for k = 1:StepN
%     DCLinkVoltage(k+1) = DCLinkVoltage(k) + Ts*DCLinkCapacitorCurrent(k)/Cdc;
% end
% WindowLength = 0.005;
% DCLinkVoltagePeaktoPeak = max(DCLinkVoltage(find(timeaxis == Tfinal-WindowLength):find(timeaxis == Tfinal)))...
%     - min(DCLinkVoltage(find(timeaxis == Tfinal-WindowLength):find(timeaxis == Tfinal)));
% DCLinkVoltagePercentRipple = DCLinkVoltagePeaktoPeak/Vdcm*100;
%
% [InverterVoltageAFundRMS,InverterVoltageAFundPhase] = ...
%     fundamentalcomp(InverterVoltagePhaseA,Ts,fout);
% [InverterVoltageVABFundRMS,InverterVoltageVABFundPhase] = ...
%     fundamentalcomp(InverterVoltageVAB,Ts,fout);
% [LineCurrentAFundRMS,LineCurrentAFundPhase] = ...
%     fundamentalcomp(LineCurrentA,Ts,fout);
% [InducedVoltageAFundRMS,InducedVoltageAFundPhase] = ...
%     fundamentalcomp(InducedVoltagePhaseA,Ts,fout);
%
% THDInverterVoltagePhaseA = 100*sqrt(InverterVoltagePhaseARMS^2-...
%     InverterVoltageAFundRMS^2)/InverterVoltageAFundRMS;
% THDInverterVoltageVAB = 100*sqrt(InverterVoltageVABRMS^2-...
%     InverterVoltageVABFundRMS^2)/InverterVoltageVABFundRMS;
% THDLineCurrentA = 100*sqrt(PhaseARMSCurrent^2-...
%     LineCurrentAFundRMS^2)/LineCurrentAFundRMS; % PROBLEML? (RMS d�zg�n de?il)
% THDInducedVoltagePhaseA = 100*sqrt(InducedVoltageARMS^2-...
%     InducedVoltageAFundRMS^2)/InducedVoltageAFundRMS;
%
% InstPowerMotorPhaseA = InducedVoltagePhaseA.*LineCurrentA;
% AvgPowerMotorPhaseA = mean( InstPowerMotorPhaseA((StepN-(1/Ts)/fout):StepN) );
% InstPowerMotorPhaseB = InducedVoltagePhaseB.*LineCurrentB;
% AvgPowerMotorPhaseB = mean( InstPowerMotorPhaseB((StepN-(1/Ts)/fout):StepN) );
% InstPowerMotorPhaseC = InducedVoltagePhaseC.*LineCurrentC;
% AvgPowerMotorPhaseC = mean( InstPowerMotorPhaseC((StepN-(1/Ts)/fout):StepN) );
% AvgPowerMotor = AvgPowerMotorPhaseA + AvgPowerMotorPhaseB + AvgPowerMotorPhaseC;
%
% InstPowerInverterPhaseA = InverterVoltagePhaseA.*LineCurrentA;
% AvgPowerInverterPhaseA = mean( InstPowerInverterPhaseA((StepN-(1/Ts)/fout):StepN) );
%
% ApperantPowerInverterPhaseA = InverterVoltageAFundRMS*LineCurrentAFundRMS;
% ActivePowerInverterPhaseA = ApperantPowerInverterPhaseA*...
%     cos(pi/180*(InverterVoltageAFundPhase-LineCurrentAFundPhase));
% PowerFactorInverter = ActivePowerInverterPhaseA/ApperantPowerInverterPhaseA;
% ReactivePowerInverter = 3*ApperantPowerInverterPhaseA*...
%     sin(pi/180*(InverterVoltageAFundPhase-LineCurrentAFundPhase));
% ActivePowerInverter = 3*ApperantPowerInverterPhaseA*...
%     cos(pi/180*(InverterVoltageAFundPhase-LineCurrentAFundPhase));





%% PLAN:

% From transistor currents, calculate losses

% Find AC and DC spsctrums

% Extend the topology to Series, Parallel, Series/Parallel
% Try different PWM techniques on this model (2-Level)

% Convertert the model to 3-Level inverter topology
% Try different PWM techniques on this model (3-Level)



%%
% figure;
% %plot(timeaxis(1:StepN),DCLinkCurrent(1:StepN),'b-','Linewidth',1);
% plot(timeaxis(1:StepN),DCLinkRipplesim(1:StepN),'b-','Linewidth',1);
% hold on;
% %plot(timeaxis(1:StepN),DCLinkCurrentsim(1:StepN)','r-','Linewidth',1);
% %plot(timeaxis(1:StepN),DCLinkCapacitorCurrent(1:StepN),'k-','Linewidth',1);
% %hold on;
% plot(timeaxis(1:StepN),DCLinkVoltage(1:StepN),'r-','Linewidth',1);
% hold on;
% %plot(timeaxis,InducedVoltagePhaseA,'m-','Linewidth',2);
% %hold on;
% %plot(timeaxis,ModSignalPhaseA*Vdcm*0.612*sqrt(2)/sqrt(3),'g-','Linewidth',2);
% hold off;
% grid on;
% set(gca,'FontSize',12);
% xlabel('Time (s)','FontSize',12,'FontWeight','Bold')
% %ylabel('Motor Phase Induced Voltages (Volts)','FontSize',12,'FontWeight','Bold')
% %legend('Phase-A','Phase-B','Phase-C');
% %legend('Carrier Signal','Modulating Signal','PWM Output');
% %ylim([-2 2]);
% %xlim([0 0.02])
%
%
% %DCLinkCurrentsim
% %DCLinkRipplesim
%
% %%
%
% % Plots
% figure;
% plot(timeaxis,LineCurrentA(1:StepN+1),'k-','Linewidth',1);
% hold on;
% plot(timeaxis,LineCurrentB(1:StepN+1),'r-','Linewidth',1);
% hold on;
% plot(timeaxis,LineCurrentC(1:StepN+1),'b-','Linewidth',1);
% hold on;
% %plot(timeaxis,DCLinkCurrent(1:StepN+1),'b-','Linewidth',1);
% %hold on;
% %plot(timeaxis,DCLinkCapacitorCurrent(1:StepN+1),'k-','Linewidth',1);
% %hold on;
% %plot(timeaxis,DCLinkVoltage(1:StepN+1),'r-','Linewidth',1);
% %hold on;
% %plot(timeaxis,InducedVoltagePhaseA,'m-','Linewidth',2);
% %hold on;
% %plot(timeaxis,ModSignalPhaseA*Vdcm*0.612*sqrt(2)/sqrt(3),'g-','Linewidth',2);
% hold off;
% grid on;
% set(gca,'FontSize',12);
% xlabel('Time (s)','FontSize',12,'FontWeight','Bold')
% %ylabel('Motor Phase Induced Voltages (Volts)','FontSize',12,'FontWeight','Bold')
% %legend('Phase-A','Phase-B','Phase-C');
% %legend('Carrier Signal','Modulating Signal','PWM Output');
% %ylim([-2 2]);
% %xlim([0 0.02])
%
% %%
% figure;
% %plot(timeaxis(1:StepN),DCLinkCurrent(1:StepN),'b-','Linewidth',1);
% hold on;
% %plot(timeaxis(1:StepN),DCLinkCapacitorCurrent(1:StepN),'k-','Linewidth',1);
% hold on;
% plot(timeaxis(1:StepN),DCLinkVoltage(1:StepN),'r-','Linewidth',1);
% hold on;
% %plot(timeaxis,InducedVoltagePhaseA,'m-','Linewidth',2);
% %hold on;
% %plot(timeaxis,ModSignalPhaseA*Vdcm*0.612*sqrt(2)/sqrt(3),'g-','Linewidth',2);
% hold off;
% grid on;
% set(gca,'FontSize',12);
% xlabel('Time (s)','FontSize',12,'FontWeight','Bold')
% %ylabel('Motor Phase Induced Voltages (Volts)','FontSize',12,'FontWeight','Bold')
% %legend('Phase-A','Phase-B','Phase-C');
% %legend('Carrier Signal','Modulating Signal','PWM Output');
% %ylim([-2 2]);
% %xlim([0 0.02])
%
%
% %% BELOW ARE NOT USED
% %Rin = 10;
% %Lin = 1e-3;
% %Vin = Vdc + Rin*(Pout/Vdc);



% WindowCycle = 1;
% SampleInWindow = WindowCycle/(Ts*fout);
% MaxHarmonic = 1;
% FourierSeriesAk = zeros(1,MaxHarmonic);
% FourierSeriesBk = zeros(1,MaxHarmonic);
% FourierSeriesAo = zeros(1,1);
% %FunctionHarmonic = InducedVoltagePhaseA;
% %FunctionHarmonic = LineCurrentA;
% FunctionHarmonic = InverterVoltageVAB;
% for k = 1:SampleInWindow
%     radang = (k-1)*pi/(SampleInWindow/2);
%     radang = double(radang);
%     FourierSeriesAo = FourierSeriesAo+FunctionHarmonic(1,k);
%     for l = 1:MaxHarmonic
%         FourierSeriesAk(l) = FourierSeriesAk(l)+FunctionHarmonic(1,k)*cos(l*radang);
%         FourierSeriesBk(l) = FourierSeriesBk(l)+FunctionHarmonic(1,k)*sin(l*radang);
%     end
% end
% DCValue = FourierSeriesAo/SampleInWindow;
%
%
% for l = 1:MaxHarmonic
%     a = 2*FourierSeriesAk(l)/SampleInWindow;
%     b = 2*FourierSeriesBk(l)/SampleInWindow;
%     peak_magn(l) = sqrt(a.^2+b.^2);
%     fprintf('\n%gth:%g\n',l,peak_magn(l)/sqrt(2));
% end


%
%
% FourierSeriesAk = 0;
% FourierSeriesBk = 0;
% FourierSeriesAo = 0;
% FunctionHarmonic = InverterVoltagePhaseA;
% %FunctionHarmonic = LineCurrentA;
% %FunctionHarmonic = InverterVoltageVAB;
% for k = 1:SampleInWindow
%     FourierSeriesAo = FourierSeriesAo+FunctionHarmonic(k);
%     FourierSeriesAk = FourierSeriesAk+FunctionHarmonic(k)*...
%         cos(double((k-1)*pi/(SampleInWindow/2)));
%     FourierSeriesBk = FourierSeriesBk+FunctionHarmonic(k)*...
%         sin(double((k-1)*pi/(SampleInWindow/2)));
% end
% DCValue = FourierSeriesAo/SampleInWindow
% CosValue = 2*FourierSeriesAk/SampleInWindow;
% SinValue = 2*FourierSeriesBk/SampleInWindow;
% FundamentalPeak = sqrt(CosValue.^2 + SinValue.^2);
% FudamentalRMS = FundamentalPeak/sqrt(2)
%
%
%

%     LineCurrentA(count+1) = LineCurrentA(count) + ...
%         Ts*((InverterVoltagePhaseA(count)-Vdcm/2-InducedVoltagePhaseA(count))/Ls);
%     LineCurrentB(count+1) = LineCurrentB(count) + ...
%         Ts*((InverterVoltagePhaseB(count)-Vdcm/2-InducedVoltagePhaseB(count))/Ls);
%     LineCurrentC(count+1) = LineCurrentC(count) + ...
%         Ts*((InverterVoltagePhaseC(count)-Vdcm/2-InducedVoltagePhaseC(count))/Ls);
%