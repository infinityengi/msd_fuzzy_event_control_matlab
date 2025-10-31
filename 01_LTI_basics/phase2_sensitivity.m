% phase2_sensitivity.m
% Sweep c and k and plot pole movement
m = 1;
c_vals = linspace(0.1,5,50);
k_vals = [5 10 20 50];

figure('Name','Pole trajectories','NumberTitle','off');
hold on;
colors = lines(numel(k_vals));
for i = 1:numel(k_vals)
    poles = zeros(2,numel(c_vals));
    for j = 1:numel(c_vals)
        A = [0 1; -k_vals(i)/m -c_vals(j)/m];
        p = eig(A);
        poles(:,j) = p;
    end
    plot(real(poles(1,:)), imag(poles(1,:)),'Color',colors(i,:));
    plot(real(poles(2,:)), imag(poles(2,:)),'Color',colors(i,:),'LineStyle',':');
end
xlabel('Real part'); ylabel('Imaginary part');
title('Pole trajectories for varying damping c and different k values');
legend(arrayfun(@(x) sprintf('k=%.1f',x),k_vals,'UniformOutput',false));
grid on; hold off;
