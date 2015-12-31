fid = fopen ("/home/asanka/Downloads/myfifo");

txt="0";

while(txt!=-1)
	txt=fgetl(fid);
	if(txt!=-1)
		txt
	end
end

fclose (fid);

