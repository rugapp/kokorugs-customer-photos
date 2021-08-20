module Form = {
  module Label = %styled.label(`
  font-size: 1rem;
  line-height: 1.5rem;
  display: block;
  margin-top: 2rem;
  cursor: pointer;

  strong {
    display: block;
  }

  input {
    font-size: 1rem;
    line-height: 2rem;
    display: block;
    height: 3rem;
    width: 80%;
    padding: 0.5rem;
    box-sizing: border-box;
    border-radius: 0.25rem;
    border: 1px solid black;
  }
`)

  module SubmitButton = %styled.button(`
  display: block;
  font-size: 1rem;
  line-height: 3rem;
  padding: 0.5rem 2rem;
  box-sizing: border-box;
  border: none;
  background-color: dodgerblue;
  color: white;
  cursor: pointer;
  margin-top: 2rem;
  border-radius: 0.25rem;
`)
}

module Nav = %styled.nav(`
  display: flex;

  a, button {
    border: 0;
    border-radius: 0.5rem;
    padding: 0.5rem;
    margin-right: 0.5rem;
    background-color: #efefef;
  }

  a {
    color: blue;
    text-decoration: underline;

    &.active {
      color: inherit;
      text-decoration: none;
      background-color: antiquewhite;
    }
  }
`)
