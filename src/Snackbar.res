@react.component
let make = (~isOpen, ~children) => {
  <dialog className="Snackbar" open_={isOpen}> {children} </dialog>
}
