defmodule StoryTeller.UniverseTest do
  use ExUnit.Case, async: false
  doctest StoryTeller.Universe

  test "universe scene" do
    # {:ok, scene, _story} = StoryTeller.Universe.opening_scene()
    {:ok, scene, _story} = universe_opening_scene()

    opening_scene =
      scene
      |> extract_json_block()
      |> Jason.decode!()
      |> StoryTeller.Scene.parse()

    assert opening_scene = %StoryTeller.Scene{
             description:
               "O sol poente tinge o céu em tons de laranja e púrpura, pintando as nuvens de um rosa vibrante.  Uma brisa suave sopra através da Floresta de Eldoria, carregando o aroma de pinheiros e terra úmida.  Árvores antigas, com troncos grossos e retorcidos, se erguem como sentinelas silenciosas, seus galhos entrelaçados formando um dossel denso. Um caminho de pedras, quase encoberto pela vegetação, serpenteia através da floresta, levando a uma clareira iluminada por vaga-lumes cintilantes. No centro da clareira, encontra-se um círculo de pedras antigas, cobertas por musgo e líquens, emanando um brilho suave e misterioso.  O ar está carregado de uma energia quase palpável, um sussurro mágico que parece ecoar entre as árvores.",
             location: "Clareira na Floresta de Eldoria, próximo ao Rio Cristalino.",
             players: [
               %StoryTeller.Player{
                 name: "Lysandra",
                 race: "Elfa da Floresta",
                 class: "Arqueira",
                 equipment: nil,
                 backstory:
                   "Filha de um renomado caçador, abandonou sua tribo em busca de um antigo artefato lendário."
               },
               %StoryTeller.Player{
                 name: "Torvin",
                 race: "Anão da Montanha",
                 class: "Guerreiro",
                 equipment: nil,
                 backstory:
                   "Expulso de sua comunidade por desrespeitar as leis ancestrais, busca redenção através de atos heroicos."
               },
               %StoryTeller.Player{
                 name: "Zephyr",
                 race: "Meio-elfo",
                 class: "Mago",
                 equipment: nil,
                 backstory:
                   "Um jovem aprendiz que fugiu de sua torre após descobrir um segredo sombrio sobre seu mestre."
               }
             ],
             npcs: [
               %StoryTeller.NPC{
                 name: "Anya",
                 race: "Sábia",
                 description:
                   "Uma anciã misteriosa, vestida com túnicas cinzas e coberta por diversos amuletos, sentada em uma das pedras do círculo. Seus olhos azuis brilham com uma sabedoria antiga e profunda."
               }
             ],
             items: [
               %StoryTeller.Item{
                 name: "Cajado de Carvalho Ancião",
                 description:
                   "Um cajado esculpido em madeira de Carvalho Ancião, com inscrições rúnicas brilhando levemente. Parece exalar um poder mágico."
               }
             ],
             story: [],
             actions: []
           }
  end

  def extract_json_block("```json\n" <> rest) do
    rest
    |> String.trim()
    |> String.trim_trailing("```")
  end

  def extract_json_block(text), do: text

  defp universe_opening_scene() do
    {:ok,
     "```json\n{\n  \"scene\": {\n    \"description\": \"O sol poente tinge o céu em tons de laranja e púrpura, pintando as nuvens de um rosa vibrante.  Uma brisa suave sopra através da Floresta de Eldoria, carregando o aroma de pinheiros e terra úmida.  Árvores antigas, com troncos grossos e retorcidos, se erguem como sentinelas silenciosas, seus galhos entrelaçados formando um dossel denso. Um caminho de pedras, quase encoberto pela vegetação, serpenteia através da floresta, levando a uma clareira iluminada por vaga-lumes cintilantes. No centro da clareira, encontra-se um círculo de pedras antigas, cobertas por musgo e líquens, emanando um brilho suave e misterioso.  O ar está carregado de uma energia quase palpável, um sussurro mágico que parece ecoar entre as árvores.\",\n    \"location\": \"Clareira na Floresta de Eldoria, próximo ao Rio Cristalino.\",\n    \"players\": [\n      {\n        \"name\": \"Lysandra\",\n        \"race\": \"Elfa da Floresta\",\n        \"class\": \"Arqueira\",\n        \"backstory\": \"Filha de um renomado caçador, abandonou sua tribo em busca de um antigo artefato lendário.\"\n      },\n      {\n        \"name\": \"Torvin\",\n        \"race\": \"Anão da Montanha\",\n        \"class\": \"Guerreiro\",\n        \"backstory\": \"Expulso de sua comunidade por desrespeitar as leis ancestrais, busca redenção através de atos heroicos.\"\n      },\n      {\n        \"name\": \"Zephyr\",\n        \"race\": \"Meio-elfo\",\n        \"class\": \"Mago\",\n        \"backstory\": \"Um jovem aprendiz que fugiu de sua torre após descobrir um segredo sombrio sobre seu mestre.\"\n      }\n    ],\n    \"npcs\":[\n        {\n            \"name\": \"Anya\",\n            \"race\": \"Sábia\",\n            \"description\": \"Uma anciã misteriosa, vestida com túnicas cinzas e coberta por diversos amuletos, sentada em uma das pedras do círculo. Seus olhos azuis brilham com uma sabedoria antiga e profunda.\"\n        }\n    ],\n    \"items\": [\n      {\n        \"name\": \"Cajado de Carvalho Ancião\",\n        \"description\": \"Um cajado esculpido em madeira de Carvalho Ancião, com inscrições rúnicas brilhando levemente. Parece exalar um poder mágico.\"\n      }\n    ]\n  }\n}\n```\n",
     [
       %{
         parts: [
           %{
             text:
               "Você é um simulador de mundos de RPG. Retorne um JSON estruturado descrevendo uma cena e os personagens presentes.\n\nFormato:\n{\n  \"scene\": {\n    \"description\": \"...\",\n    \"location\": \"...\",\n    \"players\": [\n      {\n        \"name\": \"Drakaw\",\n        \"race\": \"Meio-dragão\",\n        \"class\": \"Bardo\",\n        \"backstory\": \"Fugiu do Circo de Lunei...\"\n      }\n    ]\n  }\n}\n\nAgora, gere a cena de abertura de um mundo mítico de RPG.\n"
           },
           %{text: "Generate the opening scene of a mythic RPG world."}
         ],
         role: "user"
       },
       %{
         parts: [
           %{
             text:
               "```json\n{\n  \"scene\": {\n    \"description\": \"O sol poente tinge o céu em tons de laranja e púrpura, pintando as nuvens de um rosa vibrante.  Uma brisa suave sopra através da Floresta de Eldoria, carregando o aroma de pinheiros e terra úmida.  Árvores antigas, com troncos grossos e retorcidos, se erguem como sentinelas silenciosas, seus galhos entrelaçados formando um dossel denso. Um caminho de pedras, quase encoberto pela vegetação, serpenteia através da floresta, levando a uma clareira iluminada por vaga-lumes cintilantes. No centro da clareira, encontra-se um círculo de pedras antigas, cobertas por musgo e líquens, emanando um brilho suave e misterioso.  O ar está carregado de uma energia quase palpável, um sussurro mágico que parece ecoar entre as árvores.\",\n    \"location\": \"Clareira na Floresta de Eldoria, próximo ao Rio Cristalino.\",\n    \"players\": [\n      {\n        \"name\": \"Lysandra\",\n        \"race\": \"Elfa da Floresta\",\n        \"class\": \"Arqueira\",\n        \"backstory\": \"Filha de um renomado caçador, abandonou sua tribo em busca de um antigo artefato lendário.\"\n      },\n      {\n        \"name\": \"Torvin\",\n        \"race\": \"Anão da Montanha\",\n        \"class\": \"Guerreiro\",\n        \"backstory\": \"Expulso de sua comunidade por desrespeitar as leis ancestrais, busca redenção através de atos heroicos.\"\n      },\n      {\n        \"name\": \"Zephyr\",\n        \"race\": \"Meio-elfo\",\n        \"class\": \"Mago\",\n        \"backstory\": \"Um jovem aprendiz que fugiu de sua torre após descobrir um segredo sombrio sobre seu mestre.\"\n      }\n    ],\n    \"npcs\":[\n        {\n            \"name\": \"Anya\",\n            \"race\": \"Sábia\",\n            \"description\": \"Uma anciã misteriosa, vestida com túnicas cinzas e coberta por diversos amuletos, sentada em uma das pedras do círculo. Seus olhos azuis brilham com uma sabedoria antiga e profunda.\"\n        }\n    ],\n    \"items\": [\n      {\n        \"name\": \"Cajado de Carvalho Ancião\",\n        \"description\": \"Um cajado esculpido em madeira de Carvalho Ancião, com inscrições rúnicas brilhando levemente. Parece exalar um poder mágico.\"\n      }\n    ]\n  }\n}\n```\n"
           }
         ],
         role: "model"
       }
     ]}
  end
end
