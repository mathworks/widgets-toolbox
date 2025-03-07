classdef ErrorHandling < handle
    %ErrorHandling Error handling methods
    
%   Copyright 2020-2025 The MathWorks Inc.
    
    methods ( Access = protected )
        
        function throwError(obj,err,title)
            % Throws an error to a dialog
            
            % Validate arguments
            arguments
                obj (1,1) wt.mixin.ErrorHandling
                err % string or MException
                title (1,1) string = "Internal Error in " + class(obj)
            end
            
            % Prepare the message
            % Was an exception provided?
            if isa(err,'MException')
                message = err.message;
            else
                message = string(err);
            end
            
            % Locate ancestor figure
            if isprop(obj,"Figure")
                fig = obj.Figure; %#ok<MCNPN>
            else
                fig = ancestor(obj,'figure');
            end
            
            % Place in a dialog if possible
            if ~isempty(fig)
                uialert(fig,message,title);
            elseif isa(err,'MException')
                err.throwAsCaller();
            else
                error(message);
            end
            
        end %function
        
        
        function dlg = showProgress(obj,title,message,cancelOn)
            % Places a progress dialog in the widget's figure
            
            % Validate arguments
            arguments
                obj (1,1) wt.mixin.ErrorHandling
                title (1,1) string = "Please Wait"
                message (1,1) string = ""
                cancelOn (1,1) logical = false
            end
            
            % Locate ancestor figure
            if isprop(obj,"Figure")
                fig = obj.Figure; %#ok<MCNPN>
            else
                fig = ancestor(obj,'figure');
            end
            
            % Place in a dialog if possible
            if isempty(fig)
                dlg = matlab.ui.dialog.ProgressDialog.empty(0,0);
            else
                dlg = uiprogressdlg(fig,...
                    "Title",title,...
                    "Message",message,...
                    "Cancelable",cancelOn);
            end
            
        end %function
        
        
        function dlg = showIndeterminateProgress(obj,title,message,cancelOn)
            % Places an indeterminate progress dialog in the widget's figure
            
            % Validate arguments
            arguments
                obj (1,1) wt.mixin.ErrorHandling
                title (1,1) string = "Please Wait"
                message (1,1) string = ""
                cancelOn (1,1) logical = false
            end
            
            dlg = showProgress(obj,title,message,cancelOn);
            dlg.Indeterminate = true;
            
        end %function
        
        
        function result = promptForConfirmation(obj,message,title,buttonNames)
            % Places an indeterminate progress dialog in the widget's figure
            
            % Validate arguments
            arguments
                obj (1,1) wt.mixin.ErrorHandling
                message (1,1) string = "Are you sure?"
                title (1,1) string = ""
                buttonNames (1,2) string = ["Yes","Cancel"]
            end
           
            % Locate ancestor figure
            if isprop(obj,"Figure")
                fig = obj.Figure; %#ok<MCNPN>
            else
                fig = ancestor(obj,'figure');
            end
            
            % Place in a dialog if possible
            if isempty(fig)

                id = "wt:mixin:ErrorHandling:NoFigure";
                msg = "No figure is present to place the dialog.";
                warning(id,msg);
                result = false;

            else

                selection = uiconfirm(fig, message, title,...
                    "Options", buttonNames, "DefaultOption", 2);
                result = matches(buttonNames(1), selection);

            end

        end %function
        
    end %methods
    
end %classdef 

