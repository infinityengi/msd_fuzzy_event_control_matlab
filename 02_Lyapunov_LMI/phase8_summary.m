% phase8_summary.m prints status and displays plots
if ~exist('02_Lyapunov_LMI/phase8_test_results.mat','file')
    warning('Results not found run phase8_apply_and_test first');
else
    load('02_Lyapunov_LMI/phase8_test_results.mat');
    fprintf('Phase 8 test transmissions %d\n', num_sent);
    figure;
    plot(tvec,x(1,:)); hold on; plot(tvec(sent_idx), x(1,sent_idx),'k+');
    title('Phase 8 result position and transmissions'); xlabel('Time seconds');
end
