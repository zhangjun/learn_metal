
func array_run() {
  var n = 2
  while n < 100 {
	n *= 2
  } 
  print(n)

  var m = 2
  repeat {
    m *= 2
  } while m < 100
  print(m)
}

func greet(person: String, day: String) -> String {
  return "Hello \(person), today is \(day)."
}

func greet(_ person: String, on day: String) -> String {
  return "Hello \(person), today is \(day)."
}

func main() {
  array_run()
  let res = greet(person:"Bob", day: "Tuesday")
  let res1 = greet("John", on: "Wednesday")
  print(res, res1)
}

main()
