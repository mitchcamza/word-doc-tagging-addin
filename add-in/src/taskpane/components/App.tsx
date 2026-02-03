import * as React from "react";

export interface AppProps {
  title: string;
}

const App: React.FC<AppProps> = ({ title }) => {
  // State for selected tag
  const [selectedTag, setSelectedTag] = React.useState<string>("Revenue");
  
  // State for status messages
  const [status, setStatus] = React.useState<string>("Ready to tag document sections");
  
  // State for button loading
  const [isTagging, setIsTagging] = React.useState<boolean>(false);

  // Available tag options
  const tagOptions = ["Revenue", "Expenses", "Risk", "Other"];

  // Handle tag selection button click
  const handleTagSelection = async () => {
    setIsTagging(true);
    setStatus("Tagging selection...");

    try {
      await Word.run(async (context) => {
        // For now, just test that we can access the selection
        const selection = context.document.getSelection();
        selection.load("text");
        await context.sync();

        // Temporary: Just show what was selected
        if (selection.text.length === 0) {
          setStatus("⚠️ Please select text to tag");
        } else {
          setStatus(`✓ Tagged as "${selectedTag}" (${selection.text.length} characters)`);
        }
      });
    } catch (error) {
      console.error("Error tagging selection:", error);
      setStatus("❌ Error: " + error.message);
    } finally {
      setIsTagging(false);
    }
  };

  return (
    <div className="app-container">
      <header className="app-header">
        <h1>{title}</h1>
        <p className="subtitle">Tag document sections for accounting workflows</p>
      </header>

      <main className="app-main">
        <section className="tagging-section">
          <label htmlFor="tag-select" className="input-label">
            Select Tag Category:
          </label>
          <select
            id="tag-select"
            className="tag-dropdown"
            value={selectedTag}
            onChange={(e) => setSelectedTag(e.target.value)}
            disabled={isTagging}
          >
            {tagOptions.map((tag) => (
              <option key={tag} value={tag}>
                {tag}
              </option>
            ))}
          </select>

          <button
            className="tag-button"
            onClick={handleTagSelection}
            disabled={isTagging}
          >
            {isTagging ? "Tagging..." : "Tag Selection"}
          </button>
        </section>

        <section className="status-section">
          <div className="status-line">{status}</div>
        </section>

        <section className="info-section">
          <h3>How to use:</h3>
          <ol>
            <li>Select text in your Word document</li>
            <li>Choose a tag category from the dropdown</li>
            <li>Click "Tag Selection"</li>
          </ol>
        </section>
      </main>
    </div>
  );
};

export default App;