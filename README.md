# Table

Everybody's favorite table flipper, lightly animated

## Setup

Download and execute immediately:

```sh
bash <(curl -s https://raw.githubusercontent.com/gagregrog/table/main/table.sh)
```

Or, download and then run:

```sh
curl https://raw.githubusercontent.com/gagregrog/table/main/table.sh > table.sh 
chmod u+x table.sh
./table.sh
```

## Help

```
############################################################################
# table.sh                                                    (╯°□°) ╯︵┻─┻
############################################################################

Everybody's favorite table flipper, lightly animated

Options:
  -f, --fps           [int]            change the running speed (default 60)
  -h, --help                           display this help

Actors:
  --actor             [actor]         choose a specific actor

    actors: bear, burns, diss, jake, pwny, rage, scream, zen

Actor Options:
  -e,  --eye          [char(s)]        customize flip's eyes
  -m,  --mouth        [char(s)]        customize flip's mouth
  -cl, --cheek-left   [char(s)]        customize flip's left cheek
  -cr, --cheek-right  [char(s)]        customize flip's right cheek
  -a,  --arm          [char(s)]        customize flip's flippin' arms
  -M,  --motion       [char(s)]        customize the table flippin' motion

Table Options:
  -t, --table-length  [int]            change the length of the table

Scenes:
  -s, --scan                           like a printer...but not really
  -c, --clear                          like shell clear, but better (worse)
```

