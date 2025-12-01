function [param] = extract_pmu(twix_obj, timeShift, inspect)
% twix_obj: the object from mapVBVD, load the PMUTime and TimeStamp
% timeShift: bool, shift the TimeStamp to the beginning of 0
    if isempty(timeShift)
        timeShift = 1;
    end
    if isempty(inspect)
        inspect = 1;
    end
    PMUTimeStamp    = double( twix_obj.image.pmutime );
    TimeStamp       = double( twix_obj.image.timestamp );

  if timeShift
        TimeStamp       = TimeStamp - min(TimeStamp);
  end
    % Do not forget to scale the times by costTime (Setting from Siemens)
    costTime = 2.5;

    PMUTimeStamp_ms = PMUTimeStamp * costTime;
    PMUTimeStamp_s  = PMUTimeStamp_ms / 1000;
    TimeStamp_ms    = TimeStamp * costTime;
    TimeStamp_s     = TimeStamp_ms / 1000;

    % Save all the param to struct "param"
    param.PMUTimeStamp_ms   = PMUTimeStamp_ms;
    param.PMUTimeStamp_s    = PMUTimeStamp_s;
    param.TimeStamp_ms      = TimeStamp_ms;
    param.TimeStamp_s       = TimeStamp_s;

    
    if inspect
        figure;
        plot(param.TimeStamp_ms, param.PMUTimeStamp_ms);
        % xlim([0 1e4]);  % Set x-axis limits
        % ylim([0 180]); % Set y-axis limits
        xlabel('TimeStamp (ms)');
        ylabel('PMU TimeStamp (ms)');
        title('Time vs. PMU Stamp');
    end
    Timediff = TimeStamp_ms(end) - TimeStamp_ms(1);
    disp(['The duration of the rawdata is: ', num2str(Timediff), ...
    ' ms with data points:', num2str(length(TimeStamp_s)) ]);

end

