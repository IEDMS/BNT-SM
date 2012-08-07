function log_message(fid_log, format, varargin)

  args = varargin;
internal_format = ['At %s : ' format];
fprintf(internal_format, datestr(now), args{:});
fprintf(fid_log, internal_format, datestr(now), args{:});


