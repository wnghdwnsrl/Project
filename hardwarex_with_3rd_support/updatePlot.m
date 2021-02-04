function updatePlot(surface,data)
    surface.ZData(data(1)) = data(2);
    drawnow('limitrate');
end
