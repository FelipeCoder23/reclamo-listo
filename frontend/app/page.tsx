import { describeHealth, getApiHealth } from "@/lib/api";

export const dynamic = "force-dynamic";

export default async function Home() {
  const health = await getApiHealth();

  return (
    <main>
      <h1>Reclamo Listo</h1>
      <p>
        Describe tu problema con una compra y recibe un veredicto con los
        artículos de la ley, tu reclamo listo para el SERNAC y un mensaje para
        la tienda.
      </p>
      <p>
        <strong>Estado:</strong> {describeHealth(health)}
      </p>
      <p>
        <small>
          Esta herramienta orienta y no reemplaza asesoría legal. No es un sitio
          oficial del SERNAC.
        </small>
      </p>
    </main>
  );
}
