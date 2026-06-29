import { Route, Routes } from "react-router-dom"
import Home from "./Home"
import Korzina from "./KorzinkaShoping"

export default function App() {
  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/Korzina" element={<Korzina />} />
    </Routes>
  )
}