package de.wwu.maml.maml2md2.rules.controller

import de.wwu.maml.dsl.maml.DataSource
import de.wwu.maml.dsl.maml.InteractionProcessElement
import de.wwu.maml.dsl.maml.UseCase
import de.wwu.maml.dsl.mamldata.ComplexType
import de.wwu.maml.dsl.mamldata.Multiplicity
import de.wwu.maml.dsl.mamlgui.Attribute
import de.wwu.maml.maml2md2.rules.Elem2Elem
import de.wwu.maml.maml2md2.rules.view.Attribute2Attribute
import de.wwu.maml.maml2md2.rules.view.Attribute2ViewElement
import de.wwu.maml.maml2md2.rules.view.ProcessElement2ViewFrame
import de.wwu.md2.framework.mD2.AbstractViewFrameRef
import de.wwu.md2.framework.mD2.AbstractViewGUIElementRef
import de.wwu.md2.framework.mD2.Button
import de.wwu.md2.framework.mD2.CallTask
import de.wwu.md2.framework.mD2.ContentProvider
import de.wwu.md2.framework.mD2.ContentProviderPath
import de.wwu.md2.framework.mD2.Controller
import de.wwu.md2.framework.mD2.CustomAction
import de.wwu.md2.framework.mD2.ElementEventType
import de.wwu.md2.framework.mD2.EventBindingTask
import de.wwu.md2.framework.mD2.FireEventAction
import de.wwu.md2.framework.mD2.MappingTask
import de.wwu.md2.framework.mD2.PathTail
import de.wwu.md2.framework.mD2.ProcessChain
import de.wwu.md2.framework.mD2.ProcessChainStep
import de.wwu.md2.framework.mD2.SimpleActionRef
import de.wwu.md2.framework.mD2.ViewAction
import de.wwu.md2.framework.mD2.ViewElementEventRef
import de.wwu.md2.framework.mD2.ViewFrame
import de.wwu.md2.framework.mD2.ViewGUIElement
import de.wwu.md2.framework.mD2.WorkflowElement
import de.wwu.md2.framework.mD2.WorkflowEvent
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet

import static extension de.wwu.maml.maml2md2.util.MamlHelper.*

class ProcessElement2WorkflowElement extends Elem2Elem {
	
	public static final String ruleID = "ProcessElement->WorkflowElement"
	public static final String ruleIDinitAction = ruleID + "[initAction]"
	public static final String ruleIDinitActionAttrBinding = ruleID + "[initialBinding]"
	public static final String ruleIDworkflowEvent = "ProcessElement->WorkflowEvent"
	public static final String ruleIDviewAction = ruleIDworkflowEvent + "[viewAction]"
	public static final String ruleIDaction = ruleIDworkflowEvent + "[action]"
	public static final String ruleIDactionButton = ruleIDworkflowEvent + "[button]"
	
	new(ResourceSet src, ResourceSet trgt, Resource corr) {
		super(src, trgt, corr)
	}
	 
	/* 
	 * Dependencies:
	 * - ViewFrame
	 * - ViewElements
	 * - ContentProvider
	 */
	override def sourceToTarget() {
		sourceModel.allContents.filter(typeof(InteractionProcessElement))
			.forEach[src |
				// Create default process chain
				val defaultPc = createTargetElement(targetPackage.processChain) as ProcessChain
				defaultPc.name = "defaultChain"
				
				val pcStep = createTargetElement(targetPackage.processChainStep) as ProcessChainStep
				pcStep.name = defaultPc.name + "Step1"
				val viewRef = createTargetElement(targetPackage.abstractViewFrameRef) as AbstractViewFrameRef
				viewRef.ref = src.getOrCreateCorrModelElement(ProcessElement2ViewFrame.ruleID).targetElement as ViewFrame
				pcStep.view = viewRef
				
				defaultPc.processChainSteps.add(pcStep)
				
				// Create workflow element
				val corr = src.getOrCreateCorrModelElement(ruleID)
				val wfe = corr.getOrCreateTargetElem(targetPackage.workflowElement) as WorkflowElement
				wfe.name = src.toUniqueName(src.workflowElementName).toFirstUpper
				wfe.processChain.add(defaultPc)
				wfe.defaultProcessChain = defaultPc
				
				val initAction = src.getOrCreateMd2InitAction()
				wfe.actions.add(initAction)
				wfe.initActions.add(initAction)
				
				// Attach to container
				val container = resolveElement(targetPackage.controller, Model2Controller.ruleID) as Controller
				(container as Controller)?.controllerElements?.add(wfe)
				
				MD2ControllerContent.add(wfe)
			]
			
		// Process sequence of workflow elements
		sourceModel.allContents.filter(typeof(InteractionProcessElement))
			.forEach[src |
				// Find subsequent steps and create workflow events + view actions
				val nextSteps = getNextSteps(src)
				
				if(nextSteps.size == 0){
					// Final step -> End workflow
					
					// Create view button and attach to view frame
					val corr = src.getOrCreateCorrModelElement(ruleIDactionButton)
					val viewElem = corr.getOrCreateTargetElem(targetPackage.button) as Button
					viewElem.name = "finishWorkflow"
					viewElem.text = "Finish"
					val viewFrame = src.getOrCreateCorrModelElement(ProcessElement2ViewFrame.ruleID).targetElement as ViewFrame
					viewFrame.elements.add(viewElem)
					
					// Create WorkflowEvent
					val corrEvent = src.getOrCreateCorrModelElement(ruleIDworkflowEvent)
					val wfEvent = corrEvent.getOrCreateTargetElem(targetPackage.workflowEvent) as WorkflowEvent
					wfEvent.name = "finish" + (src.getOrCreateCorrModelElement(ruleID).targetElement as WorkflowElement).name.toFirstUpper
					
					// Create FireEventAction
					val fireEventAction = createTargetElement(targetPackage.fireEventAction) as FireEventAction
					fireEventAction.workflowEvent = wfEvent
					
					val simpleActionRef = createTargetElement(targetPackage.simpleActionRef) as SimpleActionRef
					simpleActionRef.action = fireEventAction
					
					// Task binding to button click
					val abstractViewElementRef = createTargetElement(targetPackage.abstractViewGUIElementRef) as AbstractViewGUIElementRef
					abstractViewElementRef.ref = viewElem
					
					val viewElementEventRef = createTargetElement(targetPackage.viewElementEventRef) as ViewElementEventRef
					viewElementEventRef.referencedField = abstractViewElementRef 
					viewElementEventRef.event = ElementEventType.ON_CLICK
					
					// Create EventBindingTask
					val fireEventBinding = createTargetElement(targetPackage.eventBindingTask) as EventBindingTask
					fireEventBinding.actions.add(simpleActionRef)
					fireEventBinding.events.add(viewElementEventRef)
					
					// Attach to workflowElement
					val initAction = src.getOrCreateMd2InitAction
					initAction.codeFragments.add(fireEventBinding)
					
				} else {
					// Has subsequent steps -> generate view actions
					nextSteps.forEach[
						val wfe = src.getOrCreateCorrModelElement(ruleID).targetElement as WorkflowElement
						val targetWfe = it.targetProcessFlowElement.getOrCreateCorrModelElement(ruleID).targetElement as WorkflowElement
						val combinationSuffix = "[->" + targetWfe.name + "]" // Ensure unique name for corrModel
						
						// Create workflow event
						val corrEvent = src.getOrCreateCorrModelElement(ruleIDworkflowEvent + combinationSuffix)
						val wfEvent = corrEvent.getOrCreateTargetElem(targetPackage.workflowEvent) as WorkflowEvent
						wfEvent.name = "start" + targetWfe.name.toFirstUpper + "Event"
						
						// Create custom action
						val corrAction = src.getOrCreateCorrModelElement(ruleIDaction + combinationSuffix)
						val action = corrAction.getOrCreateTargetElem(targetPackage.customAction) as CustomAction
						action.name = "start" + targetWfe.name.toFirstUpper + "Action"

						// Create FireEventAction and att to custom action
						val fireEventAction = createTargetElement(targetPackage.fireEventAction) as FireEventAction
						fireEventAction.workflowEvent = wfEvent
						val simpleActionRef = createTargetElement(targetPackage.simpleActionRef) as SimpleActionRef
						simpleActionRef.action = fireEventAction
						val callTask = createTargetElement(targetPackage.callTask) as CallTask
						callTask.action = simpleActionRef
						action.codeFragments.add(callTask)
						
						// Attach to workflowElement
						wfe.actions.add(action)
						
						// Create viewAction and bind custom action to view frame
						val corrViewAction = src.getOrCreateCorrModelElement(ruleIDviewAction + combinationSuffix)
						val viewAction = corrViewAction.getOrCreateTargetElem(targetPackage.viewAction) as ViewAction
						viewAction.title = it.description
						viewAction.action = action
						val viewFrame = src.getOrCreateCorrModelElement(ProcessElement2ViewFrame.ruleID).targetElement as ViewFrame
						viewFrame.viewActions.add(viewAction)
					]
				}
			]
	}
	
	override def targetToSource() {
//		targetModel.allContents.filter(typeof(de.wwu.md2.framework.mD2.Model))
//			.forEach[m |
//				val corr = m.getOrCreateCorrModelElement(ruleID)
//				val source = corr.findOrCreateSourceElemOfType(sourcePackage.model)
//				sourceModel.MAMLResource.contents += source
//			]
	}
	
	def CustomAction getOrCreateMd2InitAction(InteractionProcessElement src){
		val corr = src.getOrCreateCorrModelElement(ruleIDinitAction)
		val action = corr.getOrCreateTargetElem(targetPackage.customAction) as CustomAction
		action.name = src.workflowElementName + "InitAction"
		
		// Add initial data mappings
		src.orderedParametersFlattened.filter[it.targetElement instanceof Attribute].forEach[
			if(!(it.targetElement.type instanceof ComplexType)){ // only map lowest-level input fields
				val attr = it.targetElement as Attribute
						
				// Get content provider
				val dataSrc = (attr.eContainer as UseCase).eAllContents.filter(DataSource)?.head
				val cp = if(attr.multiplicity == Multiplicity.ONE || attr.multiplicity == Multiplicity.ZEROONE) {
						// TODO this is a simplification
						dataSrc.getOrCreateCorrModelElement(DataSource2ContentProvider.ruleID).targetElement as ContentProvider
					} else {
						dataSrc.getOrCreateCorrModelElement(DataSource2ContentProvider.ruleIDmultiCP).targetElement as ContentProvider
					}
					
				// Build content provider path
				val cpPath = createTargetElement(targetPackage.contentProviderPath) as ContentProviderPath
				cpPath.contentProviderRef = cp
				cpPath.tail = createTargetElement(targetPackage.pathTail) as PathTail
				cpPath.tail.attributeRef = attr.getOrCreateCorrModelElement(Attribute2Attribute.ruleID).targetElement as de.wwu.md2.framework.mD2.Attribute
				
				// Retrieve view element reference
				val viewElement = attr.getOrCreateCorrModelElement(Attribute2ViewElement.ruleID).targetElement as ViewGUIElement
				val ref = createTargetElement(targetPackage.abstractViewGUIElementRef) as AbstractViewGUIElementRef
				ref.ref = viewElement
				
				// Create mapping task
				val attrCorr = attr.getOrCreateCorrModelElement(ruleIDinitActionAttrBinding)
				val dataMapping = attrCorr.getOrCreateTargetElem(targetPackage.mappingTask) as MappingTask
				dataMapping.referencedViewField = ref 
				dataMapping.pathDefinition = cpPath
				
				// Attach to container
				action.codeFragments.add(dataMapping)
			}
		]
		
		return action
	}
}