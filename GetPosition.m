% global distances angles pRPLIDAR result

function [distances, angles] = GetPosition(pRPLIDAR)
   [result, distances, angles, bNewScan, quality] = GetScanDataResponseRPLIDAR(pRPLIDAR); 
   if result~=0
       fprintf('Cannot get rsponse');
       return;
   else
       sprintf('Distance at %f deg = %f m\n', angles*180.0/pi, distances);
   end
end