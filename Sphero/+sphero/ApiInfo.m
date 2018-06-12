classdef (Hidden = true) ApiInfo<hgsetget
    % APIINFO Read constants and other parameters for communication API
    %   Read the constants and other parameters that are required for the
    %   communication API to function, from specific API function. An
    %   object of this class is used as a property of the API class to
    %   access the required parameters
    %
    % Copyright 2015, The MathWorks, Inc.
    
    %% Properties
    properties (SetAccess = 'private')
        Constants %Constants associated with the API
        SpheroResponse %Structure of the Response that is expected from Sphero
    end
    %% Public Methods
    methods
        function obj = ApiInfo(ApiRev)
            obj.Constants = [];
            
            fileName = ['spheroApiRev' ApiRev];
            obj.deserialize(fileName);
        end
        
        function set(obj, property, value)
            obj.(property) = value;
        end 
        
        function deserialize(h, fileName, varargin)
        %DESERIALIZE Read the function containing information of API and save to structs
            deserializeM(h, fileName, varargin{:});
        end
        
    end
    
    methods (Access = 'private')
         function deserializeM(h, fileName, varargin)
         %DESERIALIZEM Read the file, and save it to structs
            try
                info = feval(fileName, varargin{:});
                infofields = fields(info);
                for i=1:length(infofields)
                    set(h, (infofields{i}), info.(infofields{i}));
                end
            catch ME  %#ok<NASGU>
                % OK, means no data of this type registered
            end  
         end
    end
    
        
    
end

