function [name, ext, pathd] = getfname( pathname );
%[name, ext, pathd] = getfname( pathname );

ind1 = find( pathname == '\' );
if ~isempty(ind1), 
  pathd = pathname(1:ind1(length(ind1)));
  pathname = pathname(ind1(length(ind1))+1:length(pathname));
else
  pathd = '';
end

ind2 = find( pathname == '.' );
if ~isempty(ind2), 
  ext = pathname(ind2(1)+1:length(pathname));
  pathname = pathname(1:ind2(1)-1);
else
  ext = '';
end
name = pathname;
