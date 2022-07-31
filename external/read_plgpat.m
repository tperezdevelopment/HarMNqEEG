function pat_info = read_plgpat(pat_name)

pat_info = [];
try
    [c1, c2, c3]=textread(pat_name,'%s = %d %[^\n]');
catch
    return
end
if ~exist('c1'), return; end

aa=ismember(c3,'$$ ');
ind=find(aa);
for k=1:length(ind)
    c3{ind(k)} = '';
end

c3 = char(c3);
p=find(c3 == 160); if ~isempty(p), c3(p) = 'á'; end
p=find(c3 == 130); if ~isempty(p), c3(p) = 'é'; end
p=find(c3 == 161); if ~isempty(p), c3(p) = 'í'; end
p=find(c3 == 162); if ~isempty(p), c3(p) = 'ó'; end
p=find(c3 == 163); if ~isempty(p), c3(p) = 'ú'; end
p=find(c3 == 164); if ~isempty(p), c3(p) = 'ñ'; end
p=find(c3 == 165); if ~isempty(p), c3(p) = 'Ñ'; end
p=find(c3 == '_'); if ~isempty(p), c3(p) = ' '; end
p=find(c3 == 196); if ~isempty(p), c3(p) = '_'; end

ii=strmatch('Name', c1);
if isempty(ii), pat_info.Name = ''; else pat_info.Name = deblank(c3(ii,:)); end

ii=strmatch('Code', c1);
if isempty(ii), pat_info.Code = ''; else pat_info.Code = deblank(c3(ii,:)); end

ii=strmatch('Sex', c1);
if isempty(ii), pat_info.Sex = ''; else pat_info.Sex = deblank(c3(ii,:)); end
switch lower(pat_info.Sex)
    case {'male', 'masculino'}
        pat_info.Sex = 'M';
    case {'female', 'femenino'}
        pat_info.Sex = 'F';
    otherwise
        pat_info.Sex = ' ';
end

ii=strmatch('Race', c1);
if isempty(ii), pat_info.Race = ''; else pat_info.Race = deblank(c3(ii,:)); end

ii=strmatch('BirthDate', c1);
if isempty(ii), pat_info.BirthDate = ''; else pat_info.BirthDate = deblank(c3(ii,:)); end

ii=strmatch('Age', c1);
if isempty(ii), pat_info.Age = ''; else pat_info.Age = deblank(c3(ii,:)); end

ii=strmatch('GestAge', c1);
if isempty(ii), pat_info.GestAge = ''; else pat_info.GestAge = deblank(c3(ii,:)); end

ii=strmatch('RecordDate', c1);
if isempty(ii), pat_info.RecordDate = ''; else pat_info.RecordDate = deblank(c3(ii,:)); end

ii=strmatch('RecordTime', c1);
if isempty(ii), pat_info.RecordTime = ''; else pat_info.RecordTime = strtrim(c3(ii,:)); end

ii=strmatch('Technician', c1);
if isempty(ii), pat_info.Technician = ''; else pat_info.Technician = strtrim(c3(ii,:)); end

ii=strmatch('Status', c1);
if isempty(ii), pat_info.Status = ''; else pat_info.Status = strtrim(c3(ii,:)); end

ii=strmatch('RefPhysician', c1);
if isempty(ii), pat_info.Doctor = ''; else pat_info.Doctor = strtrim(c3(ii,:)); end


texto = [];
for k=1:size(c3,1)
    cc = strtrim(c3(k, :));
    s = upper(cc);
    if ~isempty(s)
        if length(strfind(s, 'NO PROYECTO')) > 0
            pat_info.excluido = 1;
            pat_info.causa_excluido = cc;
        elseif length(strfind(s, 'REPETIR')) > 0
            pat_info.repetir = 1;
            if isfield(pat_info, 'informe_eeg')
                pat_info.informe_eeg = [pat_info.informe_eeg ' ' cc];
            else
                pat_info.informe_eeg = cc;
            end
        elseif length(strfind(s, 'EEG NORMAL')) > 0
            pat_info.eeg_normal = 1;
            if isfield(pat_info, 'informe_eeg')
                pat_info.informe_eeg = [pat_info.informe_eeg ' ' cc];
            else
                pat_info.informe_eeg = cc;
            end
        elseif length(strfind(s, 'RUIDO')) > 0 | length(strfind(s, 'ARTEFACTO')) > 0
            pat_info.eeg_normal = 0;
            if isfield(pat_info, 'informe_eeg')
                pat_info.informe_eeg = [pat_info.informe_eeg ' ' cc];
            else
                pat_info.informe_eeg = cc;
            end
        elseif length(strfind(s, 'ELECTRODO')) > 0 | length(strfind(s, 'CANAL')) > 0
            if length(strfind(s, 'MALO'))
                cc = upper(cc);
                cc = strrep(cc, 'ELECTRODOS', ''); cc = strrep(cc, 'ELECTRODO', '');
                cc = strrep(cc, 'CANALES', ''); cc = strrep(cc, 'CANAL', '');
                cc = strrep(cc, 'MALOS', ''); cc = strrep(cc, 'MALO', '');
                cc = strrep(cc, ':', ' '); cc = strrep(cc, ',', ' ');
                cc = strrep(cc, '.', ' '); cc = strrep(cc, ';', ' ');
                v = str2num(cc);
                if isempty(v)
                    pat_info.canales_malos = cc;
                else
                    pat_info.canales_malos = v;
                end
            end
        end
    end
    texto{length(texto)+1} = [c1{k} '  =  ' c3(k,:)];
%     st = strtrim(upper(c1{k}));
%     if findstr(st, 'CLINICALDATA') | findstr(st, 'DIAGNOSIS') | findstr(st, 'MEDICATION')
%         texto{length(texto)+1} = [c1{k} ' = '  c3(k,:)];
%     end
    
end
pat_info.texto = texto;
