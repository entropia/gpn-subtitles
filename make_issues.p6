use JSON::Tiny;

if "gpn13-fahrplan.json".IO !~~ :e {
    say "fahrplan json file is missing. downloading it now.";
    shell "wget http://bl0rg.net/~andi/gpn13-fahrplan.json"
}

if q:x{ghi --help} !~~ /'open' <ws> 'Open (or reopen) an issue'/ {
    die "please install the 'ghi' gem."
}

if q:x{ghi} ~~ /'Authorization required.'/ {
    die "please authenticate with ghi first:  ghi config --auth <username>"
}

my @talks = (from-json slurp "gpn13-fahrplan.json").flat;

my @commands = gather for @talks {
    # let's skip everything that's probably without video.
    next if .<confirmed> ne "Y";
    next if .<place> eq "Workshopraum" | "Hackcenter";
    next if .<type> eq "W";

    my $title = .<title>.subst(q{'}, q{\'}, :g).subst("\c[SOFT HYPHEN]", "");

    take "ghi --no-assign -L subtitle --message '$title - subtitles'"
}

.say for @commands;

given prompt("does this look right? [y/N] ") {
    when m:i/y/ {
        .say;
        shell $_ for @commands;
    }
    default {
        say "fix the script or the datafile and re-run";
    }
}
