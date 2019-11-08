%% Diego Alba - Quant. Bio - HW#4

austen = fileread('Austen.txt');
dna1 = fileread('DNA1.txt');
dna2 = fileread('DNA2.txt');

austen(regexp(austen,'\r')) = [];
dna1(regexp(dna1,'\r')) = [];
dna2(regexp(dna2,'\r')) = [];

%% Part 1

% Calcualte Probabilities
letters = ['z','x','c','v','b','n','m','a','s','d','f',...
        'g','h','j','k','l','q','w','e','r','t','y','u','i','o','p'];
Pausten = zeros(1,length(letters));
for i = 1:length(letters)
    Pausten(i) = length(regexpi(austen,letters(i)));
end
tausten = sum(Pausten);
Pausten = Pausten/tausten;

bases = ['a','c','g','t'];
Pdna1 = zeros(1,length(bases));
Pdna2 = zeros(1,length(bases));
for i = 1:length(bases)
    Pdna1(i) = length(regexpi(dna1,bases(i)));
    Pdna2(i) = length(regexpi(dna2,bases(i)));
end
tdna1 = sum(Pdna1);
tdna2 = sum(Pdna2);
Pdna1 = Pdna1/tdna1;
Pdna2 = Pdna2/tdna2;

% Entropies
Hausten = - sum(Pausten.*(log(Pausten)/log(2)));
Hdna1 = - sum(Pdna1.*(log(Pdna1)/log(2)));
Hdna2 = - sum(Pdna2.*(log(Pdna2)/log(2)));

% Conditional Probabilities
cPausten = zeros(length(letters));
cPdna1 = zeros(length(bases));
cPdna2 = zeros(length(bases));

for i = 1:length(letters)
    dummy = austen(regexpi(austen,letters(i))+1);
    for j = 1:length(letters)
        cPausten(i,j) = sum(dummy == letters(j))/length(dummy);
    end
end
clear dummy

dna1(end+1)=' ';
dna2(end+1)=' ';
for i = 1:length(bases)
    dummy1 = dna1(regexpi(dna1,bases(i))+1);
    dummy2 = dna2(regexpi(dna2,bases(i))+1);
    for j = 1:length(bases)
        cPdna1(i,j) = sum(dummy1 == bases(j))/length(dummy1); % j given i
        cPdna2(i,j) = sum(dummy2 == bases(j))/length(dummy2);
    end
end
clear dummy1 dummy2

% Conditional Entropies
Pausten = Pausten';
Pdna1 = Pdna1';
Pdna2 = Pdna2';

cHausten = 0;
for i = 1:length(letters)
    for j = 1:length(letters)
        cHausten = cHausten - nansum(Pausten(i)*(cPausten(i,j)*log(cPausten(i,j))/log(2)));
    end
%      cHausten = cHausten - nansum(Pausten.*cPausten(:,i).*...
%          log(cPausten(:,i))/log(2));
end

cHdna1 = 0;
cHdna2 = 0;
for i = 1:length(bases)
    for j = 1:length(bases)
        cHdna1 = cHdna1 - nansum(Pdna1(i)*(cPdna1(i,j)*log(cPdna1(i,j))/log(2)));
        cHdna2 = cHdna2 - nansum(Pdna2(i)*(cPdna2(i,j)*log(cPdna2(i,j))/log(2)));
    end
%     cHdna1 = cHdna1 - nansum(Pdna1.*cPdna1(:,i).*...
%         log(cPdna1(:,i))/log(2));
%     cHdna2 = cHdna2 - nansum(Pdna2.*cPdna2(:,i).*...
%         log(cPdna2(:,i))/log(2));
end
Hausten
Hdna1
Hdna2
cHausten
cHdna1
cHdna2
% Mutual Information %MARGINAL P
MIausten = Hausten - cHausten
MIdna1 = Hdna1 - cHdna1
MIdna2 = Hdna2 - cHdna2

% Mutual information was higher for Jane Austen because there are specific
% rules in English language that determine which letters can follow which
% letters. This is not the case for DNA. 

%% Part 2

% Probabilities
bases = ['a','c','g','t'];
BASES = ['A','C','G','T'];
Pdna2 = zeros(1,length(bases));
PDNA2 = zeros(1,length(BASES));
for i = 1:length(bases)
    Pdna2(i) = length(regexp(dna2,bases(i)));
    PDNA2(i) = length(regexp(dna2,BASES(i)));
end
tdna2 = sum(Pdna2);
tDNA2 = sum(PDNA2);
t = tDNA2 + tdna2;
Pdna2 = Pdna2/t;
PDNA2 = PDNA2/t;

cPdna2 = zeros(length(bases),length(bases),30);
cPDNA2 = zeros(length(BASES),length(BASES),30);

dna2(end+31)=' ';
for k = 1:30
    for i = 1:length(bases)
        dummy1 = dna2(regexp(dna2,bases(i))+k);
        dummy2 = dna2(regexp(dna2,BASES(i))+k);
        for j = 1:length(bases)
            cPdna2(i,j,k) = sum(dummy1 == bases(j))/length(dummy1);
            cPDNA2(i,j,k) = sum(dummy2 == BASES(j))/length(dummy2);
        end
    end
end
clear dummy1 dummy2

% Entropies
Hdna2 = - sum(Pdna2.*(log(Pdna2)/log(2)));
HDNA2 = - sum(PDNA2.*(log(PDNA2)/log(2)));

Pdna2 = Pdna2';
PDNA2 = PDNA2';
cHdna2 = zeros(1,k);
cHDNA2 = zeros(1,k);

for k = 1:30
    for i = 1:length(bases)
        for j = 1:length(bases)
            cHdna2(k) = cHdna2(k) - nansum(Pdna2(i)*(cPdna2(i,j,k)*log(cPdna2(i,j,k))/log(2)));
            cHDNA2(k) = cHDNA2(k) - nansum(PDNA2(i)*(cPDNA2(i,j,k)*log(cPDNA2(i,j,k))/log(2)));
        end
%         cHdna2(k) = cHdna2(k) - nansum(Pdna2.*cPdna2(:,i,k).*...
%             log(cPdna2(:,i,k))/log(2));
%         cHDNA2(k) = cHDNA2(k) - nansum(PDNA2.*cPDNA2(:,i,k).*...
%             log(cPDNA2(:,i,k))/log(2));
    end
end

% Mutual Information
MIdna2 =  Hdna2 - cHdna2;
MIDNA2 =  HDNA2 - cHDNA2;

figure
hold on
plot(1:30,MIdna2)
plot(1:30,MIDNA2)
hold off
ylabel('Mutual Information')
xlabel('k')
legend('dna','DNA')
