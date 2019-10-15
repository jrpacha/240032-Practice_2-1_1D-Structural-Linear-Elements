clearvars
close all

h=4.5;         %length of an element (in m)
P=11.0e4;      %point forces at the nodes, downwards (in N)
F=3.0e5;       %point force at the topmost node, downwads (in N)
Y=2.0e11;      %Young Modulus of the material (in N/m^2)
Area=2.5e-2;   %Setcion area of the column (in m^2)

%Geometry: nodes & elements
nodes=linspace(0,4*h,5); %nodes=0:h:18;
nodes=nodes';
elem=[1,2;
      2,3;
      3,4;
      4,5];

numNod=size(nodes,1);
numElem=size(elem,1);

%Real constants: materials and section area
E=Y*ones(1,numElem);
A=Area*ones(1,numElem);

%Assembly
K=zeros(numNod);
for e=1:numElem
    Ke=localStiffnessMatrix1D(E,A,nodes,elem,e);
    rows=[elem(e,1),elem(e,2)];
    files=rows;
    K(files,rows)=K(files,rows)+Ke;
end

%Natural B.C.
Q=zeros(numNod,1);
Q(2:numNod)=-2*P;
Q(numNod)=-F;

%Essential B.C
fixedNodes=1;
freeNodes=setdiff(1:numNod,fixedNodes);
u=zeros(numNod,1);
u(fixedNodes)=0.0;

%Set the reduced system
Qm = Q(freeNodes) - K(freeNodes,fixedNodes)*u(fixedNodes);
Km = K(freeNodes,freeNodes);
um = Km\Qm;
u(freeNodes)=um;
format short e
u

%Post-process
%(I) Reaction Forces
reactForces = K*u-Q

%(II) Final lenght, stress and force at the elements
displ=zeros(numElem,1);
stress=zeros(numElem,1);
force=zeros(numElem,1);

for e=1:numElem
    displ(e) = u(elem(e,2))-u(elem(e,1));
    L = abs(nodes(elem(e,2))-nodes(elem(e,1)));
    stress(e) = E(e)*displ(e)/L;
    force(e) = A(e)*stress(e);
end

disp(['displ. ','force ','stress:'])
[displ,force,stress]

%Fancy output (not for exams!!!)
fprintf('\nFancy output: not for exams!!!\n')
fprintf('\n%6s%8s%13s%17s\n','Nod.','Y','U','Reac.F')
fprintf('%4d%14.4e%14.4e%14.4e\n',...
    [[1:numNod]',nodes,u,reactForces]')
fprintf("\n%6s%12s%11s%15s\n",...
    'Elem.','elongation','force','stress')
fprintf('%4d%14.4e%14.4e%14.4e\n',...
    [[1:numElem]',displ,force,stress]')
