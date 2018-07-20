staload UN = "prelude/SATS/unsafe.sats"
staload "prelude/SATS/string.sats"

fun min_3(x : int, y : int, z : int) : int =
  min(x, (min(y, z)))

fun bool2int(x : char, y : char) : int =
  if x = y then
    0
  else
    1

// Ported over from https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#C
fn levenshtein {m:nat}{n:nat}(s1 : string(m), s2 : string(n)) : int =
  let
    val s1_l: size_t = string_length(s1)
    val s2_l: size_t = string_length(s2)
    val column: arrszref(int) = arrszref_make_elt(s1_l + 1, 0)
    
    fun print_loop {i:nat}(i : int(i)) : void =
      case+ i of
        | 0 => ()
        | k =>> (print_loop(k - 1) ; print!(column[k]))
    
    fun loop1 { i : nat | i <= m }(i : int(i)) : void =
      case+ i of
        | 0 => ()
        | i =>> {
          val () = column[i] := i
          val () = loop1(i - 1)
        }
    
    val () = loop1(sz2i(s1_l))
    
    fun loop2 { i : nat | i > 0 }(x : int(i)) : void =
      if x <= sz2i(s2_l) then
        {
          val () = column[0] := x
          val () = let
            fun inner_loop { j : nat | j > 0 }(y : int(j), last_diag : int) : void =
              if y <= sz2i(s1_l) then
                let
                  val old_diag = column[y]
                  val () = column[y] := min_3( column[y] + 1
                                             , column[y - 1] + 1
                                             , last_diag + bool2int(s1[y - 1], s2[x - 1])
                                             )
                in
                  inner_loop(y + 1, old_diag)
                end
              else
                ()
          in
            inner_loop(1, x - 1)
          end
          val () = loop2(x + 1)
        }
      else
        ()
    
    val () = loop2(1)
  in
    column[s1_l]
  end

extern
fn levenshtein_vt {m:nat}{n:nat}(s1 : !strnptr(m), s2 : !strnptr(n)) : int =
  "mac#"
