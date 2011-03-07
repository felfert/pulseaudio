# This AWK script processes input files by replacing @VAR@ by its value, similar to configure does to files added to
# AC_CONFIG_FILES.  On top of that it allows the use of conditionals with @if, @else and @endif.
BEGIN {
  # Put variables from config.h into the config dictionary
  while ((getline < configfile) > 0)
    if (/^#define/) {
      value = substr($0, index($0, $2)+length($2)+1)
      if (value ~ /\".*\"/)
        value = substr(value, 2, length(value)-2)
      config[$2] = value
    }
  # Put variables from the command line into the config dictionary
  for (i = 1; i < ARGC; i++)
    if ((ind = index(ARGV[i], "=")) > 0)
      config[substr(ARGV[i], 0, ind-1)] = substr(ARGV[i], ind+1)
}
{
  # Replace all variables present in the config dictionary
  for (define in config)
    gsub("@" define "@", config[define])
  # Process the conditional statements
  if (match($0, /@if /))
    stack[++stacklen] = int(substr($0, RSTART+RLENGTH))
  else if (/@else$/)
    stack[stacklen] = !stack[stacklen]
  else if (/@endif$/)
    delete stack[stacklen--]
  else {
    printline = 1
    for (bla in stack)
      if (!stack[bla])
        printline = 0
    if (printline)
      print $0
  }
}
