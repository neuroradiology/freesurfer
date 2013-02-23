function Vars = getQdecVars(Qdec)
% Vars = getQdecVars(Qdec)
%
% Returns a one dimensional cell string array with the name of the variables
% in Qdec.
%
% Input
% Qdec: Two dimensional cell string array of Qdec data.
%
% Output
% Vars: One dimensional cell string array.
%
% $Revision: 1.1 $  $Date: 2013/02/23 21:05:16 $
% Original Author: Jorge Luis Bernal Rusiel 
% CVS Revision Info:
%    $Author: nicks $
%    $Date: 2013/02/23 21:05:16 $
%    $Revision: 1.1 $
%
Vars = Qdec(1,:)';