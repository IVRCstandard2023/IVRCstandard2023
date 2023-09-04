function stop_turtlebot(udp_send, remote_ip, n)

    for i = 1:n
        pause(0.01);
        oscsend_udpport(udp_send, remote_ip, 5005, '/brainI','ff', [0 0]);
    end
end

