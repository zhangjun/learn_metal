
func main() {
	let wrapperItem = HandlerWrapper(name: "swift cpp")

    print("name: \(wrapperItem?.getName())")

    wrapperItem?.setName("swift cpp 1.0")

    print("name: \(wrapperItem?.getName())")
}

main()
