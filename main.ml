type token_type = Number | Operator | Invalid

let token_type_to_string tt =
  match tt with
  | Number -> "Number"
  | Operator -> "Operator"
  | Invalid -> "Invalid"

type token = {
  tt: token_type;
  lit: string;
}

let string_to_list s =
  s |> String.to_seq |> List.of_seq

let rec digits acc = function
  | ('0'..'9' as d) :: rest -> digits (d :: acc) rest
  | rest -> (String.of_seq (List.to_seq (List.rev acc)), rest)

let rec tokenize lst =
  match lst with
  | [] -> []
  | x :: xs -> (
    match x with
    | '+' | '-' -> {tt = Operator; lit = String.make 1 x} :: tokenize xs
    | '0'..'9' ->
      let num, rest = digits [x] xs in
      {tt = Number; lit = num} :: tokenize rest
    | ' ' -> tokenize xs
    | _ -> {tt = Invalid; lit = String.make 1 x} :: tokenize xs
)

let print_token tkn =
  Printf.printf "{ tt = %s, lit = %s }\n" (token_type_to_string tkn.tt) tkn.lit

let rec print_tokens tks =
  match tks with
  | [] -> print_newline ()
  | x :: xs ->
    print_token x;
    print_tokens xs

let rec repl () =
  print_string "> ";
  let input = read_line () in
  match input with
  | "exit" -> exit 0
  | _ ->
    let tokens = tokenize (string_to_list input) in
    print_tokens tokens;
    repl ()

let () =
  repl ()
