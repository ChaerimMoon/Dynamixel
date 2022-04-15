if OPERATING_MODE_VALUE == 3
    %% position control (4 Byte)
    goal_position = [100 4000 500 3000];
    i = 1;
    j = 0;

    while i < length(goal_position) + 1
        tic
        j = j+1;

        % Write a goal position
        write4ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_GOAL_POSITION, typecast(int32(goal_position(i)), 'uint32'));
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        elseif dxl_error ~= 0
            fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
        end
        
        % Read the present position
        dxl_present_position = read4ByteTxRx(port_num, PROTOCOL_VERSION, DXL_ID, ADDR_PRESENT_POSITION);
        dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
        dxl_error = getLastRxPacketError(port_num, PROTOCOL_VERSION);
        if dxl_comm_result ~= COMM_SUCCESS
            fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
        elseif dxl_error ~= 0
            fprintf('%s\n', getRxPacketError(PROTOCOL_VERSION, dxl_error));
        end
        
        final_position(j) = goal_position(i);
        present_position(j) = dxl_present_position;
        fprintf('[ID:%03d] GoalPos:%03d  PresPos:%03d\n', DXL_ID, goal_position(i), typecast(uint32(dxl_present_position), 'int32'));

        if ~(abs(goal_position(i) - typecast(dxl_present_position, 'double')) > DXL_MOVING_STATUS_THRESHOLD)
                    i = i+1;
        end
        toc
    end

%% plot
figure(1)
plot(1:j,final_position * 360 / 4096, 1:j, present_position * 360/ 4096)
xlabel('Iteration')
ylabel('Angle (Degree)')
legend('Goal Position', 'Present Position')
