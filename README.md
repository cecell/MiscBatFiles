#log_error_filter.bat
  Set the following options at the top of the script
    - Whether to automatically open the output file or not
      - `set AUTO_OPEN=1`
    
    - The number of lines to include before and after the error to preserve context.
      - `set N=3`
  
    - USAGE:
      - Drag-and-drop log file onto this script.
  
  Search tokens are to the right of this: 
    - >> "%ps_script%" echo $patterns = 
  
  Each search token must be inside pipes "|" and pipes must be escaped using "^" so "^|":
    - |new_one^|
    - existing ^|new_one^| existing^|
