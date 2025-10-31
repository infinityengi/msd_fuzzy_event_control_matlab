% phase4_switch_example.m
% Two mode example for msd with different damping
m = 1; k = 10;
A1 = [0 1; -k/m -0.5/m];
A2 = [0 1; -k/m -3/m];
B = [0; 1/m];
C = [1 0]; D = 0;

% show that switching can destabilize arbitrarily chosen switching sequence
t = 0:0.001:5;
x = [0.5; 0];
xhist = zeros(2,numel(t));
mode = 1;
for idx = 1:numel(t)
    if mod(floor(idx/200),2) == 0
        A = A1;
    else
        A = A2;
    end
    xdot = A*x;
    x = x + 0.001*xdot;
    xhist(:,idx) = x;
end

figure('Name','Switching example','NumberTitle','off');
plot(t,xhist(1,:),t,xhist(2,:));
legend('x1','x2'); title('State under switching'); xlabel('Time seconds');

% Now attempt to find common P via LMI with simple static gains
