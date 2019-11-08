%% Ethanol & Water Solution
%% P-xy Diagram

% First, we define the liquid molar fraction of THF and water as a linearly-spaced, 1000-element vector from 0 to 1.

    xEtOH = linspace(0,1,1000);
    xW = 1 - xEtOH;

% From Perry's Handbook, we find the Van Laar coeffiecients for a THF and water solution, and the vapor preassure for both components at room temperature. 

% <https://accessengineeringlibrary.com/browse/perrys-chemical-engineers-handbook-eighth-edition/p200139d899713_6001>

    alpha = 1.6798;
    beta = 0.92276;
   
    VpTHF =  7.83318 ; % in kPA
    VpW = 3.18;

% With these values, we find the Van Laar activity coefficients for both components. The activity of THF and water is plotted against the liquid molar fraction of THF. 

    gammaEtOH = exp(alpha./(1+alpha.*xEtOH./beta./xW).^2);
    gammaW = exp(beta./(1+beta.*xW./alpha./xEtOH).^2);
    
    figure
    plot(xEtOH,gammaEtOH,xEtOH,gammaW)
    title('THF and Water Activities by Van Laar')
    xlabel('x_ THF')
    ylabel('gamma')
    legend('THF','Water','Location', 'southoutside')

% We define the total pressure as the sum of partial pressures, as by Dalton's Law of Partial Pressures, and use Raoult's Law to express the partial pressures as the activity times the vapor pressure.   

    P = VpTHF.*gammaEtOH.*xEtOH + VpW.*gammaW.*xW;

% We then define the vapor molar fraction of THF as the fraction of partial pressure of THF and the toal pressure. The relationship between the liquid and vapor molar fractions is plotted. 

    yTHF = VpTHF.*gammaEtOH.*xEtOH./P;
    
    figure
    plot(xEtOH,yTHF)
    title('x_ THF - y_ THF Relationship')
    xlabel('x_ THF')
    ylabel('y_ THF')
    
% %% No need
% 
% % In this section we will generate Pressure diagrams for both components. 
% 
%     figure
%     plot(xEtOH, P, yTHF, P)
%     title('Pressure as liquid and vapor THF molar fractions')
%     xlabel('x_ THF, y_ THF')
%     ylabel('P (kPa)')
%     legend('Liquid','Vapor','Location', 'southoutside')
%     figure
%     plot(xW, P, 1-yTHF, P)
%     title('Pressure as liquid and vapor Water molar fractions')
%     xlabel('x_ W, y_ W')
%     ylabel('P (kPa)')
%     legend('Liquid','Vapor','Location', 'southoutside')

%% T-xy Diagram

% From the NIST website, we find the Antoine's coeffiecients for both THF and water. We also set the total pressure to the room pressure, in bars. 

% <https://webbook.nist.gov/cgi/cbook.cgi?ID=C64175&Units=SI&Mask=4#Thermo-Phase>
% <http://webbook.nist.gov/cgi/cbook.cgi?ID=C7732185&Mask=4&Type=ANTOINE&Plot=on>

    At = 7.68117;
    Bt = 1332.04;
    Ct = 199.2;
    Aw = 6.20963; 
    Bw = 2354.731;
    Cw = 7.559;

    P2 = 1.01325; % bar

% We define a MATLAB system for T (we let T be a symbolic variable). We then use Antoine's equation to find the vapor pressures of THF and water.

    syms T
    Pt = 10.^(At-Bt./(T+Ct));
    Pw = 10.^(Aw-Bw./(T+Cw));

% We create two empty vectors to keep track of all of the temperatures and vapor molar fractions. 

    allT = [];
    yEtOH = [];

% In this section we solve for the temperature as a function of the liquid molar fraction of THF, and we find the vapor molar fraction of both components. We then plot all of the data.

% We create a loop that will iterate through the liquid molar fraction of THF, in 100 steps. For each molar fraction value, we find the corresponding activity (by Van Laars equation), and use the 'solve' function to find the temperature. We also calculate the corresponding vapor molar fraction at that temperature. 

    warning('off','all') % to avoid 'solve' warning messages
    for xEtOH2 = linspace(0,1,100)
    xW = 1 - xEtOH2;
    gammaEtOH = exp(alpha./(1+alpha.*xEtOH2./beta./xW).^2);
    gammaW = exp(beta./(1+beta.*xW./alpha./xEtOH2).^2);
    allT = [allT eval(solve(xEtOH2 ==(-Pw.*gammaW+P2)./(Pt.*gammaEtOH-Pw.*gammaW),T))];
    yEtOH = [yEtOH (10.^(At-Bt./(allT(end)+Ct)).*gammaEtOH.*xEtOH2./P2)];
    end
    warning('on','all')
    
    xEtOH2 = linspace(0,1,100);
    xW2 = 1 - xEtOH2;
    
    figure
    plot(xEtOH2,allT,'--',yEtOH,allT,'--') % with '--' to hide plot gaps
    title('Temperature as liquid and vapor THF molar fractions')
    xlim([0 1])
    xlabel('x_ THF, y_ THF')
    ylabel('T (K)')
    legend('Liquid','Vapor','Location', 'southoutside')
%     figure
%     plot(xW2, allT,'--', 1-yEtOH, allT,'--')
%     title('Temperature as liquid and vapor Water molar fractions')
%     xlim([0 1])
%     xlabel('x_ W, y_ W')
%     ylabel('T (K)')
%     legend('Liquid','Vapor','Location', 'southoutside')
    



