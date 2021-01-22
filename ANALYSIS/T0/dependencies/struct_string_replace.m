function data = struct_string_replace(data,originalstring,newstring)
% This function recursively loops through a data structure, replacing any
% instances of originalstring with newstring
% 
% Ross L. Hatton 2010


	%Identify the class of the data
	switch class(data)

		%If a cell array, call this function on each cell individually and
		%aggregate the results
		case 'cell'

			for i = 1:numel(data)

				data{i} = struct_string_replace(data{i},originalstring,newstring);

			end

		%If a structure array, break into individual structures and then
		%call on each structure element individually
		case 'struct'
			
			%If there is more than one element, break them out
			if numel(data) > 1
				
				for i = 1:numel(data)
					
					data(i) = struct_string_replace(data(i),originalstring,newstring);
					
				end
				
			%If the number of elements is nonzero, get the fieldnames, and
			%call this function on each field
			elseif numel(data) == 1

				%extract the fieldnames
				f = fieldnames(data);
				
				%loop over the fields
				for i = 1:length(f)

					data.(f{i}) = struct_string_replace(data.(f{i}),originalstring,newstring);

				end
				
			end

		%If we've found a string, make the replacement
		case 'char'
			
			data = strrep(data,originalstring,newstring);
			
		%Doubles don't have children
		case 'double'
			
			%do nothing
			
		%Handle any unexpected types
		otherwise
				
			%Assume that non-struct, non-cell elements do not contain any
			%children
			

	end

end
	