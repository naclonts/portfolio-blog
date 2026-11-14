module.exports = ({ markdownAST, markdownNode }) => {
  if (!markdownNode.frontmatter || !markdownNode.frontmatter.linksInNewTab) {
    return
  }

  const visit = node => {
    if (node.type === "link" && node.url && !node.url.startsWith("#")) {
      node.data = node.data || {}
      const properties = node.data.hProperties || {}
      const rel = new Set(
        String(properties.rel || "").split(/\s+/).filter(Boolean)
      )
      rel.add("noopener")
      rel.add("noreferrer")
      node.data.hProperties = {
        ...properties,
        target: "_blank",
        rel: [...rel].join(" "),
      }
    }
    for (const child of node.children || []) visit(child)
  }

  visit(markdownAST)
}
