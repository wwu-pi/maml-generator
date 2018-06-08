package de.wwu.maml.maml2md2.util

import de.wwu.maml.dsl.maml.AutomatedProcessElement
import de.wwu.maml.dsl.maml.DataSource
import de.wwu.maml.dsl.maml.InteractionProcessElement
import de.wwu.maml.dsl.maml.ParameterConnector
import de.wwu.maml.dsl.maml.ProcessFlowElement
import de.wwu.maml.dsl.maml.ProcessStartEvent
import de.wwu.maml.dsl.maml.Xor
import de.wwu.maml.dsl.mamldata.AnonymousType
import de.wwu.maml.dsl.mamldata.Collection
import de.wwu.maml.dsl.mamldata.CustomType
import de.wwu.maml.dsl.mamldata.DataType
import de.wwu.maml.dsl.mamldata.Enum
import java.util.Arrays
import de.wwu.maml.dsl.maml.ParameterSource
import de.wwu.maml.dsl.mamlgui.Attribute
import de.wwu.maml.dsl.maml.UseCase
import de.wwu.maml.dsl.mamlgui.GUIElement
import de.wwu.maml.dsl.maml.ProcessConnector

class MamlHelper {
	
	static def String getDataTypeName(DataType type) {
		switch type {
			Collection: return getDataTypeName(type.type) + "Coll"
			AnonymousType: return "Anonymous" + type.hashCode
			CustomType: return type.name
			Enum: return type.name
			default: return null
		}
	}
	
	static def String getViewName(InteractionProcessElement ipe){
		ipe.description?.getAllowedAttributeName.toFirstUpper + "View"
	}
	
	static def String getWorkflowElementName(InteractionProcessElement ipe){
		ipe.description?.getAllowedAttributeName.toFirstUpper + "WorkflowElement"
	}
	
	static def camelCaseToSpacedString(String text){
		val words = Arrays.asList(text.split("(?<=[a-z])(?=[A-Z])"))
		return String.join(" ", words.map[it.toFirstLower]);
	}
	
	static def String getAllowedAttributeName(String text){
		// Replace umlauts
		var out = text.replaceAll("Ä", "Ae");
		out = out.replaceAll("Ö", "Oe");
		out = out.replaceAll("Ü", "Ue");
		out = out.replaceAll("ä", "ae");
		out = out.replaceAll("ö", "oe");
		out = out.replaceAll("ü", "ue");
		out = out.replaceAll("ß", "ss");
		
		// Only alphabetic characters in front
		if(!text.matches("[a-zA-Z].*")){
			return if(out.length() <= 1) { "" } else { getAllowedAttributeName(text.substring(1)) };
		}

		// Replace spaces by camel cased name (and trim)
		if(text.contains(" ")){
			val parts = text.split(" ");
			out = "";
			for(String part : parts){
				out += part.toFirstUpper;
			}
		}
		
		// Filter only allowed characters and replace by camel cased name 
		// At the same time trim trailing spaces
		var filteredText = "";
		var nextUpper = false;
		for(char c : text.toCharArray()){
			if((c + "").matches("[a-zA-Z0-9_]")) {
				filteredText += if(nextUpper) { (c + "").toUpperCase() } else { c };
				nextUpper = false;
			} else {
				nextUpper = true;
			}
		}
		
		// First character lowercase
		return filteredText.toFirstLower;
	}
	
	static def boolean isFirstInteractionProcessElement(ProcessFlowElement pe){
		val foundStart = pe.previousElements.map[it.sourceProcessFlowElement].map[
			switch it {
				ProcessStartEvent: return true
				Xor,
				DataSource,
				AutomatedProcessElement: return isFirstInteractionProcessElement(it)
				default: return false
			}
		]
		return foundStart.exists[it === true]
	}
	
	static def getHumanCaption(ParameterConnector conn){
		if(conn.description !== null) {
			return conn.description
		} else if(conn.targetElement.description !== null){
			return conn.targetElement.description.camelCaseToSpacedString
		} else {
			return ""
		}
	}
	
	static def Iterable<ParameterConnector> getOrderedParametersFlattened(ParameterSource src){
		// Order content by specified order attribute
		val orderedParameters = src.parameters.sortBy[it.order]
		
		// Flatten indirect (nested) attributes
		return orderedParameters.flatMap[
			val target = it.targetElement
			if(target instanceof Attribute && target.type instanceof CustomType){
				return getOrderedParametersFlattened(target)
			} else {
				return newArrayList(it)
			}
		]
	}
	
	static def String maxLength(String input, int maxLength){
		if(input.length > maxLength) return input.substring(0, maxLength)
		return input 
	}
	
	static def incomingConnectors(GUIElement attr){
		return (attr.eContainer as UseCase).attributes.flatMap[it.parameters].filter[it.targetElement == attr]
	}
	
	static def getLastSegment(String qualifiedName){
		return qualifiedName.split("\\.")?.last ?: qualifiedName
	}
	
	static def getPathWithoutLastSegment(String qualifiedName){
		return qualifiedName.substring(0, qualifiedName.length - qualifiedName.lastSegment.length)
	}
	
	static def containsIgnoreCase(java.util.Collection<String> elements, String search){
		return elements.filter[it.equalsIgnoreCase(search)].size > 0
	}
	
	static def Iterable<ProcessConnector> getNextSteps(ProcessFlowElement elem){
		return elem.nextElements.flatMap[
			val target = it.targetProcessFlowElement
			var Iterable<ProcessConnector> result = null
			switch target {
				InteractionProcessElement: result = #[it]
				DataSource: result = target.getNextSteps
				Xor: result = target.getNextSteps // TODO automatically evaluated Xors
				default: result = emptyList // Unimplemented, e.g. Loop, Events ...
			}
			return result
		]
	}
}