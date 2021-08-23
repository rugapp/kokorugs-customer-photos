module TableContainer = %styled.div(`
  overflow-x: auto;
  width: 100%;

  table {
    border-collapse: collapse;
    width: 100%;
    max-width: 100%;
    min-width: 700px;

    tr {

      &:last-of-type{
        td {
          border: none;
        }
      }

      td {
        padding: 1rem 0.25rem;
        border-bottom: 1px solid rgba(0, 0, 0, 0.3);
      }
    }
  }
`)

@react.component
let make = () => {
  let (activities, setActivities) = React.useState(() => [])
  React.useEffect1(() => {
    open Firebase.Firestore

    let unsubscribe = onQuerySnapshot(
      query(collection(db, "activity"), [orderBy("date", "desc")]),
      (querySnapshot: iterable<activityData<'a>>) => {
        let activities = []
        querySnapshot->forEach(doc => {
          activities->Js.Array2.push((doc.id, doc.data(.)))
        })
        setActivities(_ => activities)
      },
    )

    Some(unsubscribe)
  }, [])

  <TableContainer>
    <table>
      <thead>
        <th> {React.string("Date")} </th>
        <th> {React.string("Event")} </th>
        <th> {React.string("Meta")} </th>
        <th> {React.string("User")} </th>
      </thead>
      {activities
      ->Js.Array2.map(((ref, activity)) =>
        <tr key=ref>
          <td>
            {React.string(
              `${activity.date->Js.Date.fromString->Js.Date.toLocaleDateString} ${activity.date
                ->Js.Date.fromString
                ->Js.Date.toLocaleTimeString}`,
            )}
          </td>
          <td>
            {switch activity.event {
            | #CustomerCreated =>
              <Link href={activity.link}> {React.string("Customer created")} </Link>
            | #CustomerUpdated =>
              <Link href={activity.link}> {React.string("Customer updated")} </Link>
            | #InvoiceCreated =>
              <Link href={activity.link}> {React.string("Invoice created")} </Link>
            }}
          </td>
          <td> {activity.meta->Js.Array2.joinWith("<br />")->React.string} </td>
          <td> {React.string(activity.user)} </td>
        </tr>
      )
      ->React.array}
    </table>
  </TableContainer>
}
