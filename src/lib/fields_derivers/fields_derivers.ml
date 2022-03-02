(** Rewrites underscore_case to camelCase. Note: Keeps leading underscores. *)
let under_to_camel s =
  let open Core_kernel in
  (* take all the underscores *)
  let prefix_us =
    String.take_while s ~f:(function '_' -> true | _ -> false)
  in
  (* remove them from the original *)
  let rest = String.substr_replace_first ~pattern:prefix_us ~with_:"" s in
  let ws = String.split rest ~on:'_' in
  let result =
    match ws with
    | [] ->
        ""
    | w :: ws ->
        (* capitalize each word separated by underscores *)
        w :: (ws |> List.map ~f:String.capitalize) |> String.concat ?sep:None
  in
  (* add the leading underscoes back *)
  String.concat [ prefix_us; result ]

let%test_unit "under_to_camel works as expected" =
  let open Core_kernel in
  [%test_eq: string] "fooHello" (under_to_camel "foo_hello") ;
  [%test_eq: string] "fooHello" (under_to_camel "foo_hello___") ;
  [%test_eq: string] "_fooHello" (under_to_camel "_foo_hello__")

(** Like Field.name but rewrites underscore_case to camelCase. *)
let name_under_to_camel f = Fieldslib.Field.name f |> under_to_camel

let introspection_query_raw =
  {graphql|
  query IntrospectionQuery {
    __schema {
      queryType { name }
      mutationType { name }
      subscriptionType { name }
      types {
        ...FullType
      }
      directives {
        name
        description
        locations
        args {
          ...InputValue
        }
      }
    }
  }
  fragment FullType on __Type {
    kind
    name
    description
    fields(includeDeprecated: true) {
      name
      description
      args {
        ...InputValue
      }
      type {
        ...TypeRef
      }
      isDeprecated
      deprecationReason
    }
    inputFields {
      ...InputValue
    }
    interfaces {
      ...TypeRef
    }
    enumValues(includeDeprecated: true) {
      name
      description
      isDeprecated
      deprecationReason
    }
    possibleTypes {
      ...TypeRef
    }
  }
  fragment InputValue on __InputValue {
    name
    description
    type { ...TypeRef }
    defaultValue
  }
  fragment TypeRef on __Type {
    kind
    name
    ofType {
      kind
      name
      ofType {
        kind
        name
        ofType {
          kind
          name
          ofType {
            kind
            name
            ofType {
              kind
              name
              ofType {
                kind
                name
                ofType {
                  kind
                  name
                }
              }
            }
          }
        }
      }
    }
  }
  |graphql}
