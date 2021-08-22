@val external window: 'a = "window"
@val external location: 'a = "location"
@val external document: 'a = "document"
@new external image: 'a = "Image"
@new external fileReader: 'a = "FileReader"
@val external crypto: 'a = "crypto"
@new external uint8Array: 'a => 'b = "Uint8Array"
@val external url: 'a = "URL"

let resizeAndHashImageFromFile = (~max=2048, file) =>
  Promise.make((resolve, reject) => {
    let canvas = document["createElement"](. "canvas")
    let img = image
    img["onload"] = (. ()) => {
      let max = max->Belt.Float.fromInt
      let (width, height) = if img["width"] > img["height"] {
        if img["width"] > max {
          (max, img["height"] *. max /. img["width"])
        } else {
          (img["width"], img["height"])
        }
      } else if img["height"] > max {
        (img["width"] *. max /. img["height"], max)
      } else {
        (img["width"], img["height"])
      }
      canvas["width"] = width
      canvas["height"] = height
      canvas["getContext"](. "2d")["drawImage"](. img, 0, 0, width, height)->ignore
      canvas["toBlob"](.(. blob) => {
        let reader = fileReader
        reader["onloadend"] = (. ()) => {
          crypto["subtle"]["digest"](. "SHA-1", reader["result"])
          ->Promise.then(hashBuffer => {
            let hash =
              Js.Array2.from(uint8Array(hashBuffer))
              ->Js.Array2.map(b => b["toString"](. 16)["padStart"](. 2, "0"))
              ->Js.Array2.joinWith("")

            resolve(. (blob, hash))->Promise.resolve
          })
          ->Promise.catch(error => {
            reject(. error)->Promise.resolve
          })
        }
        reader["readAsArrayBuffer"](. blob)
      })
    }
    img["src"] = url["createObjectURL"](. file)
  })
