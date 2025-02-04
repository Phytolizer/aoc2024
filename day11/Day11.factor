USING: combinators formatting io kernel math math.parser
    sequences splitting ;
IN: Day11

MEMO:: stones-n ( n blinks -- m )
    n >dec :> name
    {
        {
            [ blinks 0 = ] 
            [ 1 ]
        }
        {
            [ n 0 = ] 
            [ 1 blinks 1 - stones-n ]
        }
        {
            [ name length even? ]
            [
                name
                dup length 2 /i
                cut
                [ string>number blinks 1 - stones-n ] bi@
                +
            ]
        }
        [ 2024 n * blinks 1 - stones-n ]
    } cond
    ;
    
:: stones ( input n -- m )
    input " " split
    0 [ string>number n stones-n + ] reduce
    ;
    
: part1 ( s -- n ) 25 stones ;
: part2 ( s -- n ) 75 stones ;

: solve ( -- )
    [
        [ part1 ] [ part2 ] bi
        "Part 1: %d\nPart 2: %d\n" printf
    ] each-line
    ;

MAIN: solve
