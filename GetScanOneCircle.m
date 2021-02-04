function [alldistances, allangles]=GetScanOneCircle(pRPLIDAR)
    alldistances = zeros(1,360); allangles = zeros(1,360);
    [result] = ClearCacheRPLIDAR(pRPLIDAR);
    if result~=0
        fprintf('버퍼 초기화 실패\n');
        return
    end
    for count=1:360
        [result, distances, angles, bNewScan, quality] = GetScanDataResponseRPLIDAR(pRPLIDAR);
        alldistances(count) = distances; allangles(count) = angles; 
    end
end