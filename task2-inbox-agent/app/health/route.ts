export type Health = { status: "ok"; service: string };

export function GET(): Response {
  const body: Health = { status: "ok", service: "task2-inbox-agent" };
  return Response.json(body);
}
