const { execSync } = require("child_process")

const firstCommit = execSync("git rev-list --max-parents=0 HEAD")
  .toString()
  .trim()

const tags = execSync("git tag")
  .toString()
  .trim()
  .split("\n")
  .reverse()
  .map((tag, index, tags) => {
    const previousTag = tags[index + 1] ?? firstCommit
    const commits = execSync(`git log --oneline ${previousTag}..${tag}`)
      .toString()
      .trim()
      .split("\n")
      .map((commit) => `- ${commit}`)
      .join("\n")

    return `## ${tag}\n\n${commits}`
  })
  .join("\n\n")

const changelog = `
  # Changelog

  This file was auto-generated by [generate-changelog.js](./generate-changelog.js).

  ${tags}
  `.trim()
process.stdout.write(changelog)
process.exit(0)
