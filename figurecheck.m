function [fg,args,nargs] = figurecheck(varargin)

% Copy of axescheck() function to check if it is figure and extract
% arguments

args = varargin;
nargs = nargin;
fg=[];
if (nargs > 0) && (numel(args{1}) == 1) && ishghandle(args{1},'figure')
  fg = args{1};
  args = args(2:end);
  nargs = nargs-1;
end
if nargs > 0
  inds = find(strcmpi('parent',args));
  if ~isempty(inds)
    inds = unique([inds inds+1]);
    pind = inds(end);
    if nargs >= pind && ishghandle(args{pind})
      fg = args{pind};
      args(inds) = [];
      nargs = length(args);
    end
  end
end