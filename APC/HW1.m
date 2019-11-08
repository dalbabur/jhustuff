%% THC & Water Solution
% *Prompt* 
%
% The	 past	 decade	 has	 witnessed	 significant research on clathrate	
% hydrates.	Clathrate	hydrates	have	found	applications	in	the	storage	and	
% transportation	 of	 various	 gases,	 and	 can	 be	 also	 be	 used	 in	 CO2
% sequestration.	 Tetrahydrofuran	 (THF)	 is	 a	 heterocyclic	 ether	 which	 is	
% readily	miscible	with	water,	and	 stands	out	as	a	potential	material	 for	
% hydrate	 formation.	 To	 understand	 the	 conditions	 that	 lead	 to	 the	
% formation	 of	 hydrates,	 it	 is	 imperative	 to	 investigate	 the	
% thermodynamics	of	a	THF-water	mixture.	Under	the	assumption	that	van	
% Laar	correlations	apply	to	the	non-ideality	of	a	THF-water	mixture,	plot	
% the	 (a)	 P	 vs	 x,	 y	 and	 (b)	 T	 vs	 x,	 y	 diagram	 at	 room	 temperature	 and	
% pressure.	Use	the	van	Laar	equation	for	activity	coefficients.
%
% All of the plots will be at the end of the code for each section. Tables
% with all the values will be presented at the end of the last problem (end of the file). 
%% P-xy Diagram

% First, we define the liquid molar fraction of THF and water as a linearly-spaced, 1000-element vector from 0 to 1.

    xTHF = linspace(0,1,1000);
    xW = 1 - xTHF;

% From Perry's Handbook, we find the Van Laar coeffiecients for a THF and water solution, and the vapor preassure for both components at room temperature. 

% <https://accessengineeringlibrary.com/browse/perrys-chemical-engineers-handbook-eighth-edition/p200139d899713_6001>

    alpha = 3.0216;
    beta = 1.9436;

    VpTHF = 21.65; % in kPA
    VpW = 3.18;

% With these values, we find the Van Laar activity coefficients for both components. The activity of THF and water is plotted against the liquid molar fraction of THF. 

    gammaTHF = exp(alpha./(1+alpha.*xTHF./beta./xW).^2);
    gammaW = exp(beta./(1+beta.*xW./alpha./xTHF).^2);
    
    figure
    plot(xTHF,gammaTHF,xTHF,gammaW)
    title('THF and Water Activities by Van Laar')
    xlabel('x_ THF')
    ylabel('gamma')
    legend('THF','Water','Location', 'southoutside')

% We define the total pressure as the sum of partial pressures, as by Dalton's Law of Partial Pressures, and use Raoult's Law to express the partial pressures as the activity times the vapor pressure.   

    P = VpTHF.*gammaTHF.*xTHF + VpW.*gammaW.*xW;

% We then define the vapor molar fraction of THF as the fraction of partial pressure of THF and the toal pressure. The relationship between the liquid and vapor molar fractions is plotted. 

    yTHF = VpTHF.*gammaTHF.*xTHF./P;
    
    figure
    plot(xTHF,yTHF)
    title('x_ THF - y_ THF Relationship')
    xlabel('x_ THF')
    ylabel('y_ THF')

% In this section we will generate Pressure diagrams for both components. 

    figure
    plot(xTHF, P, yTHF, P)
    title('Pressure as liquid and vapor THF molar fractions')
    xlabel('x_ THF, y_ THF')
    ylabel('P (kPa)')
    legend('Liquid','Vapor','Location', 'southoutside')
    figure
    plot(xW, P, 1-yTHF, P)
    title('Pressure as liquid and vapor Water molar fractions')
    xlabel('x_ W, y_ W')
    ylabel('P (kPa)')
    legend('Liquid','Vapor','Location', 'southoutside')

%% T-xy Diagram

% From the NIST website, we find the Antoine's coeffiecients for both THF and water. We also set the total pressure to the room pressure, in bars. 

% <http://webbook.nist.gov/cgi/cbook.cgi?ID=C109999&Mask=4&Type=ANTOINE&Plot=on#ANTOINE>
% <http://webbook.nist.gov/cgi/cbook.cgi?ID=C7732185&Mask=4&Type=ANTOINE&Plot=on>

    At = 4.12118;
    Bt = 1202.942;
    Ct = -46.818;
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
    yTHF2 = [];

% In this section we solve for the temperature as a function of the liquid molar fraction of THF, and we find the vapor molar fraction of both components. We then plot all of the data.

% We create a loop that will iterate through the liquid molar fraction of THF, in 100 steps. For each molar fraction value, we find the corresponding activity (by Van Laars equation), and use the 'solve' function to find the temperature. We also calculate the corresponding vapor molar fraction at that temperature. 

    warning('off','all') % to avoid 'solve' warning messages
    for xTHF2 = linspace(0,1,100)
    xW = 1 - xTHF2;
    gammaTHF = exp(alpha./(1+alpha.*xTHF2./beta./xW).^2);
    gammaW = exp(beta./(1+beta.*xW./alpha./xTHF2).^2);
    allT = [allT eval(solve(xTHF2 ==(-Pw.*gammaW+P2)./(Pt.*gammaTHF-Pw.*gammaW),T))];
    yTHF2 = [yTHF2 (10.^(At-Bt./(allT(end)+Ct)).*gammaTHF.*xTHF2./P2)];
    end
    warning('on','all')
    
    xTHF2 = linspace(0,1,100);
    xW2 = 1 - xTHF2;
    
    figure
    plot(xTHF2,allT,'--',yTHF2,allT,'--') % with '--' to hide plot gaps
    title('Temperature as liquid and vapor THF molar fractions')
    xlim([0 1])
    xlabel('x_ THF, y_ THF')
    ylabel('T (K)')
    legend('Liquid','Vapor','Location', 'southoutside')
    figure
    plot(xW2, allT,'--', 1-yTHF2, allT,'--')
    title('Temperature as liquid and vapor Water molar fractions')
    xlim([0 1])
    xlabel('x_ W, y_ W')
    ylabel('T (K)')
    legend('Liquid','Vapor','Location', 'southoutside')
    



